require 'sinatra'
require 'sinatra/config_file'
require 'google_calendar'
require 'json'
require 'date'
if settings.development?
  require 'dotenv'
  Dotenv.load
end


class Main < Sinatra::Base

  helpers do
    def protected!
      return if params['token'] && params['token'].chomp.to_s == ENV['SLACK_TOKEN']
      halt 401, "Not authorized\n"
    end
  end

  get '/' do

    protected!
    # The response to this request will be sent as JSON.
    # content_type :json

    # The calendars to search for availability
    calendars = {
      "Coast" => ENV['COAST'],
      "Meadow" => ENV['MEADOW'],
      "Vista" => ENV['VISTA'],
      "Hotel 253" => ENV['HOTEL_253'],
      "Hotel 254" => ENV['HOTEL_254']
    }

    # If we received a `minutes` parameter for time, use that number, otherwise default to 30 minutes.
    if params['text'] && params['text'].chomp.to_i > 0
      duration = params['text'].chomp.to_i
    else
      duration = 30
    end

    # Setup Time objects for now and the end time for this search.
    time_start = Time.now
    time_end = time_start + 60*duration

    # Instantiate a new Google Calendar API 'FreeBusy' connection object.
    cal = Google::Freebusy.new(
      :client_id     => ENV['GOOGLE_CLIENT_ID'],
      :client_secret => ENV['GOOGLE_CLIENT_SECRET'],
      :refresh_token => ENV['GOOGLE_REFRESH_TOKEN'],
      :redirect_url  => "urn:ietf:wg:oauth:2.0:oob"
    )

    # Make an array from the IDs in the calendars hash.
    list = calendars.values

    # Run the FreeBusy request to the Google Calendar API
    check = cal.query(list, time_start, time_end)

    # An empty array for the rooms that are available.
    available = []

    # See which calendars returned an empty array (= available)
    check.each { |key, value|
      if value.empty?
        available.push(key)
      end
    }

    # Empty array for the names of each available room
    names = []

    # Add available room names to the names array
    calendars.each { |name, id|
      if available.include?(id)
        names.push(name)
      end
    }

    # Construct a Slack message to indicate: <rooms> are available for <mins> minutes.
    msg = ''

    if !names.empty?
      if names.length == 1
        msg = "The #{names.join(", ")} room is available for #{duration.to_s} minutes."
      elsif names.length == 2
        msg = "The #{names.join(" and ")} rooms are available for #{duration.to_s} minutes."
      else
        rooms = [names[0...-1].join(", "), names.last].join(", and ")
        msg = "The #{rooms} rooms are available for #{duration.to_s} minutes."
      end
    else
      msg = "Bummer. No rooms are available for #{duration.to_s} minutes."
    end

    # Return the response to this request.
    body = msg

  end

  not_found do
    erb :not_found
  end

end
