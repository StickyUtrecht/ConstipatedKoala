# Public API creating an ical file which can be downloaded
class Api::CalendarsController < ApiController
  def show
    respond_to do |format|
      format.html
      format.ics do
        @calendar = Icalendar::Calendar.new
        @calendar.x_wr_calname = 'Sticky Activities'

        update_calendar(@calendar)

        render plain: @calendar.to_ical
      end
    end
  end

  private

  # TODO: dry this up, move logic to the model
  def update_calendar(calendar)
    @activities = Activity.where(
      '(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
      Date.today, Date.today
    ).where(is_viewable: true).order(:start_date)

    @activities.each do |a|
      create_event(a, @calendar)
    end

    calendar.publish
  end

  # TODO: move this to model, as a method on the instance.
  def create_event(activity, calendar)
    event = Icalendar::Event.new
    event.dtstart = activity.start
    event.dtend = activity.end
    event.summary = activity.name
    event.url = activity_url(activity)

    event.description = activity.description + '\n' unless activity.description.blank?
    event.location = activity.location

    unless activity.price.nil? || activity.price == 0
      if activity.description.nil?
        event.description = "Price: €" + activity.price.to_s
      else
        event.description += "Price: €" + activity.price.to_s
      end
    end

    event.alarm do |a|
      a.trigger = "-PT2H"
      a.summary = activity.description
    end

    calendar.add_event(event)
  end
end
