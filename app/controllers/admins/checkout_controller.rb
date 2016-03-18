class Admins::CheckoutController < ApplicationController
  #impressionist :actions => [ :add_card_to_member, :activate_card, :change_funds, :subtract_funds ]
  protect_from_forgery except: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]

  skip_before_action :authenticate_user!, only: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]
  skip_before_action :authenticate_admin!, only: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]

  before_action :authenticate_checkout, only: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]

  respond_to :json

  def information_for_card
    respond_with CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid])
  end

  def change_funds
    if params[:uuid]
      card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )

    elsif params[:member_id]
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_balance => CheckoutBalance.find_by_member_id!(params[:member_id]) )

    else
      render :status => :bad_request, :json => ''
      return
    end

    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved => exception
      render :status => :request_entity_too_large, :json => ''
      return
    rescue ActiveRecord::RecordInvalid
      render :status => :bad_request, :json => ''
      return
    end

    render :status => :created, :json => transaction
  end

  def subtract_funds
    card = CheckoutCard.find_by_uuid!(params[:uuid])

    if( !card.active )
      render :status => :unauthorized, :json => 'card not yet activated'
      return
    end

    transaction = CheckoutTransaction.new( :items => params[:items].to_a, :checkout_card => card )

    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved => error
      render :status => :not_acceptable, :json => {
        message: "alcohol allowed at #{Settings.liquor_time}"
      } if error.message == 'not_allowed'

      render :status => :bad_request, :json => '' if error.message == 'empty_items'

      render :status => :request_entity_too_large, :json => {
        message: 'insufficient funds',
        balance: card.checkout_balance.balance,
        items: params[:items].to_a,
        costs: transaction.price
      } if error.message == 'insufficient_funds'
      return
    end

    render :status => :created, :json => {
      uuid: card.uuid,
      first_name: card.member.first_name,
      balance: card.checkout_balance.balance,
      created_at: transaction.created_at
    }
  end

  def add_card_to_member
    if !CheckoutCard.find_by_uuid(params[:uuid]).nil?
      render :status => :conflict, :json => ''
      return
    end

    card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find_by_student_id!(params[:student]), :description => params[:description] )

    if card.save
      render :status => :created, :json => CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid]).to_json
      return
    else
      render :status => :conflict, :json => ''
      return
    end
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
      render :status => :bad_request, :json => ''
      return
    end
  end

  def products_list
    render :status => :ok, :json => CheckoutProduct.where(:active => true).select(:id, :name, :category, :price).map{ |item| item.attributes.merge({ :image => CheckoutProduct.find_by_id( item.id ).url }) }
  end

  private
  def authenticate_checkout
    if params[:token] != ENV['CHECKOUT_TOKEN']
      render :status => :forbidden, :json => ''
      return
    end
  end
end
