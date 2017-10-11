require "./mixpanel/*"
require "http/client"
require "json"
require "base64"
require "uri"

module Mixpanel
  ENDPOINT_TRACK = "http://api.mixpanel.com/track/"

  class Event
    alias Properties = Hash(String, JSON::Type | Int32) # for convenience add Int32
    JSON.mapping({
      event:      String,
      properties: Properties,
    })

    def initialize(@event : String, @properties : Properties = Properties.new)
    end
  end

  class Tracker
    @endpoint : URI
    @client : HTTP::Client
    @project_token : String

    def initialize(@project_token, endpoint_track_url : String = ENDPOINT_TRACK)
      @endpoint = URI.parse endpoint_track_url
      @client = HTTP::Client.new @endpoint
    end

    private def send(event : URI)
      @client.get event.full_path, headers: HTTP::Headers{"User-Agent" => "mixpanel.cr #{VERSION}"} do |res|
        raise "Failed to send track event: #{res.status_message}" unless res.success?
      end
    end

    private def encode(event : Event) : String
      event.properties["token"] = @project_token unless event.properties.has_key?("token")
      Base64.encode event.to_json
    end

    private def url(data : String) : URI
      url = @endpoint.dup
      url.query = "data=#{data}"
      url
    end

    def track(event : Event)
      event_url = track_url event
      send event_url
    end

    def track(name : String, properties : Event::Properties)
      track Event.new(name, properties)
    end

    def track(name : String, &block : Event::Properties ->)
      event = Event.new name
      yield event.properties
      track event
    end

    def track_url(event : Event) : URI
      data = encode event
      url data
    end

    def track_url(name : String, properties : Event::Properties) : URI
      track_url Event.new(name, properties)
    end
  end
end
