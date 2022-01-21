require 'fluent/plugin/input'
require 'shodanz'

module Fluent::Plugin
  class ShodanSearch < Input
    Fluent::Plugin.register_input('shodan_search', self)

    helpers :timer

    desc "The API key to connect to the Shodan API."
    config_param :api_key, :string, secret: true
    desc "The interval time between running queries."
    config_param :interval, :time, default: 3600
    desc "The tag to apply to each shodan entries."
    config_param :tag, :string, default: nil
    desc "The Shodan query to execute."
    config_param :query, :string
    desc "The maximum amount of pages to crawl. A 0 or negative value means to crawl all pages."
    config_param :max_pages, :integer, default: 1

    def configure(conf)
      super

      @client = Shodanz.client.new(key: @api_key)
      begin
        log.info "Shodan client properly registered", client_info: @client.info
      rescue RuntimeError => exception
        raise Fluent::ConfigError.new "Invalid Shodan API key"
      end
    end

    def multi_workers_ready?
      false
    end

    def start
      super

      timer_execute("shodan_#{self.class.name}_#{@tag}".to_sym, @interval, repeat: true, &method(:run))
    end

    private

    def run
      log.debug "Starting Shodan search", query: @query, max_pages: @max_pages
      es_time = Fluent::EventTime.now
      current_page = 0
      read_entries = 0
      loop do
        current_page += 1
        result = @client.host_search(@query, page: current_page)
        result['matches'].each do |rec|
          router.emit(@tag, es_time, rec)
        end
        read_entries += result['matches'].length
        break if (@max_pages >= 0 && current_page >= @max_pages) || read_entries >= result['total']
      end
      log.debug "Shodan search ending", query: @query, total_read: read_entries
    rescue RuntimeError => re
      log.error "Unable to execute Shodan query", query: @query, page: current_page, error: re
    rescue => exception
      log.error "Error executing Shodan query", error: exception
    end
  end
end
