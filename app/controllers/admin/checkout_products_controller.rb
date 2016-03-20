class Admin::CheckoutProductsController < ApplicationController
  impressionist :actions => [ :activate_card, :change_funds ]
  respond_to :json, only: [ :activate_card, :change_funds ]

  def index
    @products = CheckoutProduct.order(:category, :name).last_version
    @years = (2015 .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

    @total = @product.sales( params['year']).map{ |sale| sale.first[0].price * sale.first[1] unless sale.first[1].nil? }.compact.inject(:+) unless params[:id].nil?

    @new = CheckoutProduct.new

    render 'admin/apps/products'
  end

  def show
    @products = CheckoutProduct.order(:category, :name).last_version
    @years = (2015 .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

    @product = CheckoutProduct.find( params[:id] )
    @total = @product.sales( params['year']).map{ |sale| sale.first[0].price * sale.first[1] unless sale.first[1].nil? }.compact.inject(:+) unless params[:id].nil?

    render 'admin/apps/products'
  end

  def create
    @new = CheckoutProduct.new(product_post_params)

    if @new.save
      redirect_to checkout_product_path(@new)
    else
      @products = CheckoutProduct.order(:category, :name).last_version
      @years = (2015 .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

      render 'admin/apps/products'
    end
  end

  def update
    @product = CheckoutProduct.find(params[:id])

    if @product.update(product_post_params)
      # if a new product is created redirect to it
      product = CheckoutProduct.find_by_parent(@product.id)

      redirect_to checkout_product_path( product || @product.id )
    else
      @years = (2015 .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse
      @products = CheckoutProduct.order(:category, :name).last_version

      render 'admin/apps/products'
    end
  end

  def change_funds
    if params[:uuid]
      card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )

    elsif params[:member_id]
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_balance => CheckoutBalance.find_by_member_id!(params[:member_id]) )

    else
      render :status => :bad_request, :json => 'no identifier given'
      return
    end

    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved => exception
      render :status => :request_entity_too_large, :json => exception.message
      return
    rescue ActiveRecord::RecordInvalid
      render :status => :bad_request, :json => exception.message
      return
    end

    render :status => :created, :json => transaction
  end

  def activate_card
    card = CheckoutCard.find_by_uuid!(params[:uuid])

    if params[:_destroy]
      card.destroy

      render :status => :no_content, :json => ''
      return
    end

    card.update_attribute(:active, true)

    if card.save
      render :status => :ok, :json => card.to_json
      return
    else
      render :status => :bad_request, :json => card.errors.full_messages
      return
    end
  end

  private
  def product_post_params
    params.require(:checkout_product).permit( :name,
                                              :price,
                                              :category,
                                              :active,
                                              :image)
  end
end
