class CommentsController < ApplicationController
  before_action :set_product
  before_action :set_card

  def create
    @comment = @card.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      Activity.create!(
        trackable: @card,
        user: Current.user,
        action: "commented"
      )

      respond_to do |format|
        format.html { redirect_to product_card_path(@product, @card) }
        format.turbo_stream
      end
    else
      redirect_to product_card_path(@product, @card), alert: "Comment could not be saved."
    end
  end

  def destroy
    @comment = @card.comments.find(params[:id])

    if @comment.user == Current.user
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to product_card_path(@product, @card) }
        format.turbo_stream
      end
    else
      redirect_to product_card_path(@product, @card), alert: "You can only delete your own comments."
    end
  end

  private

  def set_product
    @product = Product.visible_to(Current.user).find_by!(slug: params[:product_slug])
  end

  def set_card
    @card = @product.cards.find(params[:card_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
