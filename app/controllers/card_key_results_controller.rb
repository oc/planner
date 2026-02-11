class CardKeyResultsController < ApplicationController
  before_action :set_product
  before_action :set_card
  before_action :set_card_key_result, only: [:destroy]

  def new
    @card_key_result = @card.card_key_results.build
    @available_key_results = available_key_results
  end

  def create
    @card_key_result = @card.card_key_results.build(card_key_result_params)

    if @card_key_result.save
      respond_to do |format|
        format.html { redirect_to [@product, @card], notice: "Key result linked." }
        format.turbo_stream
      end
    else
      @available_key_results = available_key_results
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @card_key_result.destroy
    respond_to do |format|
      format.html { redirect_to [@product, @card], notice: "Key result unlinked." }
      format.turbo_stream
    end
  end

  private

  def set_product
    @product = Product.visible_to(Current.user).find_by!(slug: params[:product_slug])
  end

  def set_card
    @card = @product.cards.find(params[:card_id])
  end

  def set_card_key_result
    @card_key_result = @card.card_key_results.find(params[:id])
  end

  def card_key_result_params
    params.require(:card_key_result).permit(:key_result_id, :expected_impact)
  end

  def available_key_results
    linked_ids = @card.key_result_ids
    KeyResult.joins(:objective)
             .where(objectives: { product_id: [nil, @product.id] })
             .where.not(id: linked_ids)
             .includes(:objective)
             .order("objectives.period DESC, objectives.title, key_results.title")
  end
end
