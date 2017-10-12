require "http/client"
require "base64"
require "uri"

module Mixpanel
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

    def track_url(event : Event, ip : Bool = false, redirect : String? = nil, img : Bool = false, callback : String? = nil, verbose : Bool = false) : URI
      data = encode event
      url data, ip, redirect, img, callback, verbose
    end

    def track_url(name : String, properties : Event::Properties, ip : Bool = false, redirect : String? = nil, img : Bool = false, callback : String? = nil, verbose : Bool = false) : URI
      track_url Event.new(name, properties), ip, redirect, img, callback, verbose
    end
  end
end
