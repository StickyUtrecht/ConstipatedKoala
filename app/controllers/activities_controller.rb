class ActivitiesController < ApplicationController

  def index
    @activities = Activity.all.order(start_date: :desc)
    @activity = Activity.new
  end
  
  def show
    @activity = Activity.find(params[:id])
    @recipients =  Activity.joins(:members).where('participants.paid' => false, 'participants.activity_id' => params[:id]).select(:id, :first_name, :infix, :last_name, :email)
  end
  
  def create
    @activity = Activity.new(activity_post_params)   

    if @activity.save
      redirect_to @activity
    else
      @activities = Activity.all.order(start_date: :desc)
      render 'index'
    end
  end
  
  def update
    @activity = Activity.find(params[:id])

    if @activity.update(activity_post_params)  
      redirect_to @activity
    else
      render 'show'
    end
  end
  
  def mail
    ActionMailer::Base.mail(:bcc => params[:recipients], :subject => params[:subject], :body => params[:mail]).deliver
  end
  
  private
  def activity_post_params
    params.require(:activity).permit( :name,
                                      :start_date,
                                      :end_date,
                                      :comments,
                                      :price)
  end
end
