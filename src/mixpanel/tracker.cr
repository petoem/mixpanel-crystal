require "http/client"
require "base64"
require "uri"

module Mixpanel
  # Use Mixpanel::Tracker to track events in your application. To track an event, use
  # ```
  # tracker = Mixpanel::Tracker.new "YOUR_TOKEN"
  # tracker.track "Signup", Mixpanel::Event::Properties{"username" => "Pino", "Age" => 2}
  # ```
  class Tracker
    @endpoint : URI
    @client : HTTP::Client
    @project_token : String

    # Create new `Mixpanel::Tracker` with your mixpanel token.
    def initialize(@project_token, endpoint_track_url : String = ENDPOINT_TRACK)
      @endpoint = URI.parse endpoint_track_url
      @client = HTTP::Client.new @endpoint
    end

    # Sends `HTTP::Client#get` request to tracking url.
    private def send(event : URI)
      @client.get event.full_path, headers: HTTP::Headers{"User-Agent" => "mixpanel.cr #{VERSION}"} do |res|
        raise "Failed to send track event: #{res.status_message}" unless res.success?
      end
    end

    # Sends batch request to mixpanel.
    private def send_batch(data : String)
      @client.post_form @endpoint.full_path, {"data" => data} do |res|
        raise "Failed to send track event: #{res.status_message}" unless res.success? 
      end
    end

    # Returns base64-encoded event.
    private def encode(event : Event) : String  
      Base64.strict_encode event.to_json
    end

    # Returns base64-encoded events for batch request.
    private def encode(events : Array(Event))
      Base64.strict_encode events.to_json
    end

    # Generates tracking `URI`.
    private def url(data : String, ip : Bool = false, redirect : String? = nil, img : Bool = false, callback : String? = nil, verbose : Bool = false) : URI
      url = @endpoint.dup
      request_parameters = [] of String
      request_parameters << "data=#{data}"
      request_parameters << "ip=#{ip.hash}" if ip
      request_parameters << "redirect=#{redirect}" if redirect
      request_parameters << "img=#{img.hash}" if img
      request_parameters << "callback=#{callback}" if callback
      request_parameters << "verbose=#{verbose.hash}" if verbose
      url.query = request_parameters.join "&"
      url
    end

    # Track event on mixpanel.
    def track(event : Event)
      event_url = track_url event
      send event_url
    end

    # The same as `#track` but creates a new event from name and `Event::Properties`.
    def track(name : String, properties : Event::Properties)
      track Event.new(name, properties)
    end

    # Same as `#track` but yields `Event::Properties` to the block.
    def track(name : String, &block : Event::Properties ->)
      event = Event.new name
      yield event.properties
      track event
    end
    
    # Sends all events as a batch request to mixpanel.
    def track(*events : Event::Properties)
      track events.to_a
    end

    # Sends `Array(Event::Properties)` as a batch request to mixpanel.
    def track(events : Array(Event::Properties))
      events.map! { |event| event.properties["token"] = @project_token unless event.properties.has_key?("token"); event }
      data = encode events
      send_batch data
    end

    # Generates tracking `URI` from event and request parameters.
    def track_url(event : Event, ip : Bool = false, redirect : String? = nil, img : Bool = false, callback : String? = nil, verbose : Bool = false) : URI
      event.properties["token"] = @project_token unless event.properties.has_key?("token")
      data = encode event
      url data, ip, redirect, img, callback, verbose
    end

    # Same as `#track_url` but creates a new event based on name and `Event::Properties`.
    def track_url(name : String, properties : Event::Properties, ip : Bool = false, redirect : String? = nil, img : Bool = false, callback : String? = nil, verbose : Bool = false) : URI
      track_url Event.new(name, properties), ip, redirect, img, callback, verbose
    end
  end
end
