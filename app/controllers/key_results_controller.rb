class KeyResultsController < ApplicationController
  before_action :set_objective
  before_action :set_key_result, only: [:edit, :update, :destroy, :update_progress]

  def new
    @key_result = @objective.key_results.build
  end

  def create
    @key_result = @objective.key_results.build(key_result_params)

    if @key_result.save
      respond_to do |format|
        format.html { redirect_to objectives_path, notice: "Key result created." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @key_result.update(key_result_params)
      respond_to do |format|
        format.html { redirect_to objectives_path, notice: "Key result updated." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @key_result.destroy
    respond_to do |format|
      format.html { redirect_to objectives_path, notice: "Key result deleted." }
      format.turbo_stream
    end
  end

  def update_progress
    @key_result.update!(current_value: params[:current_value])
    @key_result.update_status!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@key_result, partial: "key_results/key_result", locals: { key_result: @key_result }) }
      format.json { render json: { success: true, progress: @key_result.progress_percentage } }
    end
  end

  private

  def set_objective
    @objective = Objective.find(params[:objective_id])
  end

  def set_key_result
    @key_result = @objective.key_results.find(params[:id])
  end

  def key_result_params
    params.require(:key_result).permit(:title, :target_value, :current_value, :unit, :status)
  end
end
