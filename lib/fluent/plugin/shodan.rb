require 'fluent/plugin/input'
require 'shodanz'

module Fluent::Plugin
  class ShodanGenericInput < Input

    helpers :timer

    desc "The API key to connect to the Shodan API"
    config_param :api_key, :string
    desc "The interval time between running queries"
    config_param :interval, :time, default: 3600
    desc "The tag to apply to each shodan entries"
    config_param :tag, :string, default: nil

    def configure(conf)
      super

      @client = Shodanz.client.new(key: @api_key)
    end

    def multi_workers_ready?
      false
    end

    def start
      super

      timer_execute("shodan_#{self.class.name}_#{@tag}".to_sym, @interval, repeat: true, &method(:run))
    end
  end
end
