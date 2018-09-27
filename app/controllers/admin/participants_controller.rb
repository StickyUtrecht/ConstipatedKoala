#:nodoc:
class Admin::ParticipantsController < ApplicationController
  respond_to :json

  def create
    @activity = Activity.find_by_id params[:activity_id]
    @participant = Participant.find_or_initialize_by(
      member: Member.find(params[:member]),
      activity: @activity
    )

    new_record = @participant.new_record?
    status = new_record ? :created : :conflict

    if @participant.save
      impressionist(@participant) if new_record
      @response = @participant.attributes # TODO: refactor, very old code
      @response['price'] = @activity.price
      @response['email'] = @participant.member.email
      @response['name'] = @participant.member.name
      @response['notes'] = @participant.notes
      @response['fullness'] = @activity.fullness

      render status: status, :json => @response.to_json
    end
  end

  def update
    participant = Participant.find(params[:id])

    unless params[:reservist].nil?
      message = params[:reservist].to_b ? 'reservist' : 'participant'
      participant.update_attributes(:reservist => params[:reservist])
    end

    if !params[:paid].nil?
      message = params[:paid].to_b ? 'paid' : 'unpaid'
      participant.update_attribute(:paid, params[:paid]) unless participant.currency.nil?
    elsif !params[:price].nil?
      raise 'not a number' unless params[:price].is_number?

      message = 'price'
      participant.update_attributes(:price => params[:price])
    end

    if participant.save
      impressionist(participant, message)
      render :status => :ok,
             :json => I18n.t(message, scope: 'activerecord.messages.participant',
                                      name: participant.member.name,
                                      activity: participant.activity.name).to_json
      return
    else
      respond_with participant.errors.full_messages
    end
  end

  def destroy
    ghost_participant = Participant.destroy(params[:id])
    @response = {
      magic_reservists: [],
      fullness: ghost_participant.activity.fullness,
      reservist_count: ghost_participant.activity.reservists.count
    }

    ghost_participant.activity.instance_variable_get(:@magic_enrolled_reservists)&.each do |peep|
      item = peep.attributes
      item['price'] = peep.activity.price
      item['email'] = peep.member.email
      item['name']  = peep.member.name
      item['notes'] = peep.notes

      @response.magic_reservists << item
    end

    render :status => :ok, :json => @response.to_json
  end

  def mail
    logger.debug params[:recipients].inspect

    @activity = Activity.find_by_id!(params[:activity_id])
    render :json => Mailings::Participants.inform(@activity, params[:recipients].permit!.to_h.map { |_, item| item['email'] }, current_user.sender, params[:subject], params[:html]).deliver_later
    impressionist(@activity, "mail")
  end
end
