require "json"

module Mixpanel
  # A mixpanel tracking event.
  # ```
  # event = Mixpanel::Event.new "Signed Up"
  # event["token"] = "YOUR_TOKEN"
  # event["Referred By"] = "Friend"
  #
  # event.to_json # =>
  # {
  #   "event":      "Signed Up",
  #   "properties": {
  #     "token":       "YOUR_TOKEN",
  #     "Referred By": "Friend",
  #   },
  # }
  # ```
  class Event
    # The Properties of a `Mixpanel::Event`
    alias Properties = Hash(String, JSON::Type | Int32) # for convenience add Int32
    JSON.mapping({
      event:      String,
      properties: Properties,
    })

    # Initialize an `Event` and optionally set `Properties`.
    def initialize(@event : String, @properties : Properties = Properties.new)
    end
  end
end
