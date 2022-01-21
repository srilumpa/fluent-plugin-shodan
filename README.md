# fluent-plugin-shodan

The [Shodan](https://www.shodan.io/) plugin offers [Fluentd](https://fluentd.org/) capacities to gather data from shodan and send them to whatever system you want (on the condition Fluentd has an [output plugin](https://docs.fluentd.org/output) fitting your needs).

The Shodan plugin can adress three ways of gathering data

- by querying the [Search API](https://developer.shodan.io/api)
- by consuming the [Stream API](https://developer.shodan.io/api/stream) (WIP)
- or by consuming the [Alert API](https://developer.shodan.io/api/stream) (WIP)

The outputed "logs" follow the Shodan [Banner specification](https://datapedia.shodan.io/).

A valid API key will be necessary for this plugin to work. The Shodan Search plugin will work with a _Free_ account with limited functionnalities, but the Shodans Stream and the Shodan Alert plugins will need a subscription plan to work.

This plugin relies on the

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

Once the client is ready, a timer will be set to query the Shodan API a the interval set up in the configuration. One line of "log" will be generated per element contained in the `matches` array from the query result. An other query will be submitted to gather data fro mthe next page if

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

#### query (string) (required)

The Shodan query to execute.

#### max_pages (integer) (optional)

The maximum amount of pages to crawl. A 0 or negative value means to crawl all pages. Note that if you have a free account, querying a page other than the first one will result in a `HTTP 401` response.

Default value: `1`.

## Shodan Stream

WIP

## Shodan Alert

WIP

## Copyright

* Copyright(c) 2022 Marc-André Doll
* License
  * Apache License, Version 2.0
