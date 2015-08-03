class Admins::AppsController < ApplicationController

  def checkout    
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0
  
    @page = @offset / @limit
    @pagination = 5
 
    @transactions = CheckoutTransaction.includes(:checkout_card).order(created_at: :desc).limit(@limit).offset(@offset)
    @cards = CheckoutCard.joins(:member).select(:id, :uuid, :member_id).where(:active => false)
    
    @pages = CheckoutTransaction.count / @limit
    
    @today = CheckoutProduct.sales_per_day
  end
  
  def products
    @products = CheckoutProduct.where(:active => true).order(:category, :name)

    @product = CheckoutProduct.find( params[:id] ) unless params[:id].nil?    
    @new = CheckoutProduct.new if params[:id].nil?
  end  
  
  def create_product
    @new = CheckoutProduct.new(product_post_params)
  
    if @new.save
      redirect_to apps_product_path(@new)
    else
      @products = CheckoutProduct.where(:active => true).order(:category, :name)
      render 'admins/apps/products'
    end
  end
  
  def update_product
    @product = CheckoutProduct.find(params[:id])

    if @product.update(product_post_params)  
      redirect_to apps_product_path( CheckoutProduct.find_by_parent(@product.id) )
    else
      @products = CheckoutProduct.where(:active => true).order(:category, :name)
      render 'admins/apps/products'
    end
  end
  
  def ideal
    @transactions = IdealTransaction.find_by_date( params['date'] || Date.yesterday )
    @summary = IdealTransaction.summary( @transactions )
  end
  
  private
  def product_post_params
    params.require(:checkout_product).permit( :name,
                                              :price,
                                              :category,
                                              :image)
  end
end
