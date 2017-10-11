require "json"

module Mixpanel
  class Event
    alias Properties = Hash(String, JSON::Type | Int32) # for convenience add Int32
    JSON.mapping({
      event:      String,
      properties: Properties,
    })

    def initialize(@event : String, @properties : Properties = Properties.new)
    end
  end
end
