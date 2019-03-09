#:nodoc:
class Api::ActivitiesController < ApiController
  before_action -> { doorkeeper_authorize! 'activity-read' }, only: [:show]

  def index
    if params[:date].present?
      @activities = Activity.where('(end_date IS NULL AND start_date = ?) OR end_date <= ?', params[:date], params[:date]).order(:start_date).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)

    else
      @activities = Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', Date.today, Date.today).order(:start_date).where(is_viewable: true)
      @activities.limit!(params[:limit]).offset(params[:offset] ||= 0) if params[:limit].present?
      @activities = @activities.reject(&:ended?)
    end
  end

  def poster
    @activity = Activity.find params[:activity_id]
    redirect_to url_for @activity.poster_representation
  end

  def thumbnail
    @activity = Activity.find params[:activity_id]
    redirect_to url_for @activity.thumbnail_representation
  end

  def show
    @activity = Activity.find_by_id! params[:id]
  end

  def advertisements
    @advertisements = Advertisement.all
  end
end
