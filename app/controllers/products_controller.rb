class ProductsController < ApplicationController
  before_action :set_product, only: %i(show edit update destroy)

  # GET /products or /products.json
  def index
    @products = Product.recent
  end

  # GET /products/1 or /products/1.json
  def show; end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit; end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html do
          redirect_to product_url(@product),
                      notice: t("products.notice.create")
        end
        format.json do
          render :show, status: :created, location: @product
        end
      else
        format.html{render :new, status: :unprocessable_entity}
        format.json do
          render json: @product.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html do
          redirect_to product_url(@product),
                      notice: t("products.notice.update")
        end
        format.json do
          render :show, status: :ok, location: @product
        end
      else
        format.html do
          render :edit, status: :unprocessable_entity
        end
        format.json do
          render json: @product.errors, status: :unprocessable_entity
        end

      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      if @product.destroyed?
        format.html do
          redirect_to products_url,
                      notice: t("products.notice.destroy.success")
        end
        format.json{head :no_content}
      else
        format.html do
          redirect_to products_url,
                      alert: t("products.notice.destroy.failure")
        end
        format.json do
          render json: @product.errors, status: :unprocessable_entity
        end
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find_by(id: params[:id])
    return if @product.present?

    flash[:alert] = t("products.notice.not_found")
    redirect_to products_path
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:name)
  end
end
