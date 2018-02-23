require "./spec_helper"
require "uuid"

describe Mixpanel do
  describe "Tracker" do
    tracker = Mixpanel::Tracker.new "63777d70db1a6b84ac6936c4d07e9155"
    spec_run = UUID.random.to_s # Unique identifier for this run.

    it "single request" do
      properties = Mixpanel::Event::Properties{
        "CONTINUOUS_INTEGRATION" => ENV["CI"]? || false,
        "type"                   => "single",
        "run"                    => spec_run,
        "Random Number"          => rand 10,
      }
      tracker.track "spec", properties
    end

    it "batch request" do
      events = Array(Mixpanel::Event).new(3) do |i|
        Mixpanel::Event.new "spec", Mixpanel::Event::Properties{
          "CONTINUOUS_INTEGRATION" => ENV["CI"]? || false,
          "type"                   => "batch",
          "run"                    => spec_run,
          "Random Number"          => rand 10,
        }
      end
      tracker.track events
    end

    it "block request" do
      tracker.track "spec" do |properties|
        properties["CONTINUOUS_INTEGRATION"] = ENV["CI"]? || false
        properties["type"] = "block"
        properties["run"] = spec_run
        properties["Random Number"] = rand 10
      end
    end

    it "generate url" do
      url = tracker.track_url "spec", Mixpanel::Event::Properties{
        "CONTINUOUS_INTEGRATION" => ENV["CI"]? || false,
        "type"                   => "generate",
        "run"                    => spec_run,
        "Random Number"          => rand 10,
      }, callback: "wasTracked"

      "wasTracked(1);".should eq `curl -Ls "#{url.to_s}"`
    end
  end
end
