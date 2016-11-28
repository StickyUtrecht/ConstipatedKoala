class Users::EnrollmentsController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index ]

  def index
    @activities = Activity.where(
      '(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
        Date.today, Date.today
      ).order(:start_date)
  end
end
