# fluent-plugin-shodan

[![Unit tests](https://github.com/srilumpa/fluent-plugin-shodan/actions/workflows/ruby.yml/badge.svg)](https://github.com/srilumpa/fluent-plugin-shodan/actions/workflows/ruby.yml)
[![Ruby Gem](https://github.com/srilumpa/fluent-plugin-shodan/actions/workflows/rubygem-push.yml/badge.svg)](https://github.com/srilumpa/fluent-plugin-shodan/actions/workflows/rubygem-push.yml)
[![GPR](https://github.com/srilumpa/fluent-plugin-shodan/actions/workflows/gpr-push.yml/badge.svg)](https://github.com/srilumpa/fluent-plugin-shodan/actions/workflows/gpr-push.yml)
[![Gem Version](https://badge.fury.io/rb/fluent-plugin-shodan.svg)](https://badge.fury.io/rb/fluent-plugin-shodan)

The [Shodan](https://www.shodan.io/) plugin offers [Fluentd](https://fluentd.org/) capacities to gather data from shodan and send them to whatever system you want (on the condition Fluentd has an [output plugin](https://docs.fluentd.org/output) fitting your needs).

The Shodan plugin can adress three ways of gathering data

- by querying the [Search API](https://developer.shodan.io/api)
- by consuming the [Stream API](https://developer.shodan.io/api/stream) (WIP)
- or by consuming the [Alert API](https://developer.shodan.io/api/stream)

The outputed "logs" follow the Shodan [Banner specification](https://datapedia.shodan.io/).

A valid API key will be necessary for this plugin to work. The Shodan Search plugin will work with a _Free_ account with limited functionnalities, but the Shodans Stream and the Shodan Alert plugins will need at least a membership to work.

## Installation

### RubyGems

```
$ gem install fluent-plugin-shodan
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-shodan"
```

And then execute:

```
$ bundle
```

## Shodan Search

### Example configuration

```
<source>
  @type shodan_search
  interval 15m
  tag shodan.ssh
  query ssh
  api_key 1234567890AZERTYUIOP
</source>
```

### How it works

When Fluentd is started with `in_shodan_search`, it will create a Shodan client and passes to it the API key. It will then query the Shodan API to get the account information to check if the API key is valid. If it is not, an error will be logged and the plugin will stop.

Once the client is ready, a timer will be set to query the Shodan API a the interval set up in the configuration. One line of "log" will be generated per element contained in the `matches` array from the query result. An other query will be submitted to gather data from the next page if

- the amount of read entries is lesser than the total available entries
- the current read page is not greater than the `max_pages` parameter

### Plugin helpers

* [timer](https://docs.fluentd.org/v/1.0/plugin-helper-overview/api-plugin-helper-timer)
* See also: [Input Plugin Overview](https://docs.fluentd.org/v/1.0/input#overview)

### Configuration

#### api_key (string) (required)

The API key to connect to the Shodan API.

#### interval (time) (optional)

The interval time between running queries.

Default value: `3600`.

#### tag (string) (optional)

The tag to apply to each shodan entries.

#### query (string) (optional)

The Shodan query to execute. The query can be empty if at least one filter is set.

Default: `nil`

#### max_pages (integer) (optional)

The maximum amount of pages to crawl. A 0 or negative value means to crawl all pages. Note that if you have a free account, querying a page other than the first one will result in a `HTTP 401` response.

Default value: `1`.

#### filter (optional) (multi)

##### name (string) (required)

The name of the filter to be added to the query. Full filters list is available on the [Shodan filter reference page](https://www.shodan.io/search/filters). The filter can be negated by prepending `-` to the filter name (ex: `name -port`).

##### value (string) (required)

The value to be passed to the filter.

## Shodan Stream

WIP

## Shodan Alert

### Example configuration

```
<source>
  @type shodan_alert
  interval 15m
  alert_id GA3FRJ1HJNDPORHV
  api_key 1234567890AZERTYUIOP
</source>
```

### How it works

When Fluentd is started with `in_shodan_alert`, it will create a Shodan client and passes to it the API key. It will then query the Shodan API to get the account information to check if the API key is valid. If it is not, an error will be logged and the plugin will stop.

Once the client is ready, a timer will be set to query the Shodan Streaming API a the interval set up in the configuration. One line of log will be generated for each alert yield by the API.

### Plugin helpers

* [timer](https://docs.fluentd.org/v/1.0/plugin-helper-overview/api-plugin-helper-timer)
* See also: [Input Plugin Overview](https://docs.fluentd.org/v/1.0/input#overview)

### Configuration

#### api_key (string) (required)

The API key to connect to the Shodan API.

#### interval (time) (optional)

The interval time between running queries.

Default value: `3600`.

#### tag (string) (optional)

The tag to apply to each shodan entries. If none are given, the alert name will be used to tag each associated emitted log.

Default value: `nil`

#### alert_id (string) (optional)

The identifier of the alert to crawl. If none are given, all alerts are imported.

Default value: `nil`

## Testing

### Unit tests

1. Clone this repository
2. Install all dependencies with `bundle install`
3. Set the `SHODAN_TEST_API_KEY` environment variable with your API key
4. Run `rake` or `rake test`

### Live tests

On a system where fluentd is installed

1. Clone this repository
2. Build the gem with `gem build fluent-plugin-shodan.gemspec`
3. Install the built gem with `fluent-gem install fluent-plugin-shodan-<version>.gem`
4. Follow the [debugging guide from FluentD](https://docs.fluentd.org/plugin-development#debugging-plugins)

## Credits

This plugin heavily relies on the [shodanz](https://github.com/picatz/shodanz) gem by [Kent 'picat' Gruber](https://picatz.github.io/) which makes it really easy to query the Shodan API.

## Copyright

* Copyright(c) 2022 Marc-André Doll
* License
  * Apache License, Version 2.0
