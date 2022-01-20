require 'fluent/plugin/input'
require 'shodanz'

module Fluent::Plugin
  class ShodanGenericInput < Input

    helpers :timer

    config_param :api_key, :string
    config_param :interval, :time, default: 3600
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
