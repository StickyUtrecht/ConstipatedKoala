class Admin::ActivitiesController < ApplicationController
  impressionist :actions => [ :create, :update, :destroy ]

  def index
    @activities = Activity.study_year( params['year'] ).order(start_date: :desc)
    @years = (Activity.take(1).first.start_date.year .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

    @detailed = Activity.debtors.sort_by(&:start_date).reverse!
    @activity = Activity.new
  end

  def show
    @activity = Activity.find_by_id params[:id]
    @recipients =  @activity.participants.order('members.first_name', 'members.last_name').joins(:member).where('participants.paid = FALSE AND (participants.price IS NULL OR participants.price > 0)').select(:id, :member_id, :first_name, :email)
  end

  def create
    @activity = Activity.new(activity_post_params.except(:_destroy))

    if @activity.save
      redirect_to @activity
    else
      @activities = Activity.all.order(start_date: :desc)
      @years = (Activity.take(1).first.start_date.year .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

      @detailed = Activity.debtors.sort_by(&:start_date).reverse!

      render 'index'
    end
  end

  def update
    @activity = Activity.find_by_id params[:id]
    params = activity_post_params

    # removing the images from the S3 storage
    if params[:_destroy] == 'true'
      logger.debug 'remove poster from activity'
      params[:poster] = nil
    end

    if @activity.update(params.except(:_destroy))
      redirect_to @activity
    else
      @recipients =  @activity.participants.order('members.first_name', 'members.last_name').joins(:member).where('participants.paid' => false).select(:id, :member_id, :first_name, :email)
      render 'show'
    end
  end

  def destroy
    @activity = Activity.find_by_id params[:id]
    @activity.destroy

    redirect_to activities_path
  end

  private
  def activity_post_params
    params.require(:activity).permit( :name,
                                      :description,
                                      :start_date,
                                      :start_time,
                                      :end_date,
                                      :end_time,
                                      :comments,
                                      :price,
                                      :poster,
                                      :organized_by,
                                      :is_alcoholic,
                                      :is_enrollable,
                                      :participant_limit,
                                      :_destroy)
  end
end
