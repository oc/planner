class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.visible_to(Current.user).active.order(:name)
  end

  def show
    @cards_by_stage = @product.cards.includes(:owner).ordered.group_by(&:stage)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      @product.memberships.create!(user: Current.user, role: :owner)
      redirect_to @product, notice: "Product created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Product deleted."
  end

  private

  def set_product
    @product = Product.visible_to(Current.user).find_by!(slug: params[:slug])
  end

  def product_params
    params.require(:product).permit(:name, :slug, :description)
  end
end
