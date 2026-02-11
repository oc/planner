class ProductObjectivesController < ApplicationController
  before_action :set_product

  def index
    @objectives = @product.objectives.includes(:key_results).order(period: :desc, created_at: :desc)
    @periods = @objectives.distinct.pluck(:period)
    @current_period = params[:period] || @periods.first
    @objectives = @objectives.for_period(@current_period) if @current_period.present?
  end

  def new
    @objective = @product.objectives.build(period: current_period)
  end

  def create
    @objective = @product.objectives.build(objective_params)

    if @objective.save
      respond_to do |format|
        format.html { redirect_to product_objectives_path(@product), notice: "Objective created." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.visible_to(Current.user).find_by!(slug: params[:product_slug])
  end

  def objective_params
    params.require(:objective).permit(:title, :description, :period, :status)
  end

  def current_period
    Date.current.strftime("%Y-Q#{(Date.current.month - 1) / 3 + 1}")
  end
end
