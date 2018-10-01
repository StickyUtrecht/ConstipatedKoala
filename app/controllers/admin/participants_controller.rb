#:nodoc:
class Admin::ParticipantsController < ApplicationController
  respond_to :json

  def create
    @activity = Activity.find_by_id params[:activity_id]
    participant = Participant.find_or_initialize_by(
      member: Member.find(params[:member]),
      activity: @activity
    )

    new_record = participant.new_record?
    status = new_record ? :created : :conflict

    if participant.save
      impressionist(participant) if new_record
      @response = new_attendee_response_data(participant)

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
             :json => new_attendee_response_data(participant).to_json
    else
      respond_with participant.errors.full_messages
    end
  end

  def destroy
    ghost_participant = Participant.destroy(params[:id])
    response = {
      magic_reservists: [],
      activity: {
        fullness: ghost_participant.activity.fullness,
        reservist_count: ghost_participant.activity.reservists.count,
        paid_sum: ghost_participant.activity.paid_sum,
        price_sum: ghost_participant.activity.price_sum
      }
    }

    ghost_participant.activity.magic_enrolled_reservists&.each do |peep|
      response[:magic_reservists] << new_attendee_response_data(peep)
    end

    render :status => :ok, :json => response.to_json
  end

  def mail
    logger.debug params[:recipients].inspect

    @activity = Activity.find_by_id!(params[:activity_id])
    render :json => Mailings::Participants.inform(@activity, params[:recipients].permit!.to_h.map { |_, item| item['email'] }, current_user.sender, params[:subject], params[:html]).deliver_later
    impressionist(@activity, "mail")
  end

  private

  def new_attendee_response_data(participant)
    activity = participant.activity
    member = participant.member
    {
      participant: {
        id: participant.id,
        notes: participant.notes,
        member: {
          id: member.id,
          name: member.name,
          email: member.email
        }
      },
      activity: {
        price: activity.price,
        fullness: activity.fullness,
        paid_sum: activity.paid_sum,
        price_sum: activity.price_sum
      }
    }
  end
end
