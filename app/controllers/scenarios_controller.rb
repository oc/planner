class ScenariosController < ApplicationController
  before_action :set_product
  before_action :set_card
  before_action :set_scenario, only: [:edit, :update, :destroy]

  def new
    @scenario = @card.scenarios.build
  end

  def create
    @scenario = @card.scenarios.build(scenario_params)

    if @scenario.save
      respond_to do |format|
        format.html { redirect_to product_card_path(@product, @card) }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @scenario.update(scenario_params)
      respond_to do |format|
        format.html { redirect_to product_card_path(@product, @card) }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @scenario.destroy
    respond_to do |format|
      format.html { redirect_to product_card_path(@product, @card) }
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

  def set_scenario
    @scenario = @card.scenarios.find(params[:id])
  end

  def scenario_params
    params.require(:scenario).permit(:title, :given, :when_clause, :then_clause, :status)
  end
end
