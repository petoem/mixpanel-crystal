# mixpanel-crystal

**mixpanel-crystal** is a library for tracking events on Mixpanel from your crystal applications.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  mixpanel:
    github: petoem/mixpanel-crystal
```

## Usage

```crystal
require "mixpanel"

# Use Mixpanel::Tracker to track events in your application. To track an event, use
tracker = Mixpanel::Tracker.new "YOUR_TOKEN"
tracker.track "Signup", Mixpanel::Event::Properties{"username" => "Pino", "Age" => 2}
```

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/petoem/mixpanel-crystal/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [petoem](https://github.com/petoem) Michael Petö - creator, maintainer
