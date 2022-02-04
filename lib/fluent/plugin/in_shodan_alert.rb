require 'fluent/plugin/input'
require 'shodanz'

module Fluent::Plugin
  class ShodanAlert < Input
    Fluent::Plugin.register_input('shodan_alert', self)

    helpers :timer

    desc "The API key to connect to the Shodan API."
    config_param :api_key, :string, secret: true
    desc "The tag to apply to each shodan entries. If not defined, the alert name will be used."
    config_param :tag, :string, default: nil
    desc "The Shodan alert ID to follow. If not defined, all alerts will be followed"
    config_param :alert_id, :string, default: nil
    desc "The interval time between running queries."
    config_param :interval, :time, default: 300

    def multi_workers_ready?
      false
    end

    def configure(conf)
      super

      @client = Shodanz::Client.new(key: @api_key)
      begin
        log.info "Shodan client properly registered", client_info: @client.info
      rescue RuntimeError => exception
        raise Fluent::ConfigError.new "Invalid Shodan API key"
      end
    end

    def start
      super

      timer_execute("shodan_#{self.class.name}#{@alert_id.nil? ? "_#{@alert_id}" : '' }".to_sym, @interval, repeat: true, &method(:run))
    end

    private

    def run
      log.debug "Start polling Shodan alerts", alert_id: @alert_id

      if @alert_id.nil?
        @client.streaming_api.alerts { |alert| process_alert(alert) }
      else
        @client.streaming_api.alert(@alert_id) { |alert| process_alert(alert) }
      end
    end

    def process_alert(alert)
      router.emit(
        (@tag.nil? ? alert['shodan']['alert']['name'] : @tag),
        Fluent::EventTime.parse(alert['timestamp']),
        alert
      )
    end

  end
end