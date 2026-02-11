class ObjectivesController < ApplicationController
  before_action :set_objective, only: [:edit, :update, :destroy]

  def index
    @objectives = Objective.company_level.includes(:key_results).order(period: :desc, created_at: :desc)
    @periods = @objectives.distinct.pluck(:period)
    @current_period = params[:period] || @periods.first
    @objectives = @objectives.for_period(@current_period) if @current_period.present?
  end

  def new
    @objective = Objective.new(period: current_period)
  end

  def create
    @objective = Objective.new(objective_params)

    if @objective.save
      respond_to do |format|
        format.html { redirect_to objectives_path, notice: "Objective created." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @objective.update(objective_params)
      respond_to do |format|
        format.html { redirect_to objectives_path, notice: "Objective updated." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @objective.destroy
    respond_to do |format|
      format.html { redirect_to objectives_path, notice: "Objective deleted." }
      format.turbo_stream
    end
  end

  private

  def set_objective
    @objective = Objective.company_level.find(params[:id])
  end

  def objective_params
    params.require(:objective).permit(:title, :description, :period, :status)
  end

  def current_period
    Date.current.strftime("%Y-Q#{(Date.current.month - 1) / 3 + 1}")
  end
end
