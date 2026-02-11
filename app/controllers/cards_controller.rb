class CardsController < ApplicationController
  before_action :set_product
  before_action :set_card, only: [:show, :edit, :update, :destroy, :move]

  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @card = @product.cards.build(
      owner: Current.user,
      stage: params[:stage] || :opportunity,
      card_type: params[:card_type] || :feature
    )
    @card.initialize_gate_checklist!
  end

  def create
    @card = @product.cards.build(card_params)
    @card.owner = Current.user
    @card.initialize_gate_checklist!

    if @card.save
      respond_to do |format|
        format.html { redirect_to product_path(@product), notice: "Card created." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @card.update(card_params)
      respond_to do |format|
        format.html { redirect_to [@product, @card], notice: "Card updated." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    respond_to do |format|
      format.html { redirect_to product_path(@product), notice: "Card deleted." }
      format.turbo_stream
    end
  end

  def move
    old_stage = @card.stage
    new_stage = params[:stage]
    new_position = params[:position].to_i

    @card.stage = new_stage
    @card.insert_at(new_position)

    if @card.save
      Activity.create!(
        trackable: @card,
        user: Current.user,
        action: "moved",
        change_data: { from_stage: old_stage, to_stage: new_stage }
      )

      respond_to do |format|
        format.turbo_stream
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@card, partial: "cards/card", locals: { card: @card }) }
        format.json { render json: { success: false, errors: @card.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_product
    @product = Product.visible_to(Current.user).find_by!(slug: params[:product_slug])
  end

  def set_card
    @card = @product.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:title, :description, :card_type, :stage, :priority, :parent_id)
  end
end
