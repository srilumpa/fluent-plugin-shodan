require 'fluent/plugin/input'
require_relative 'shodan.rb'

module Fluent::Plugin
  class ShodanSearch < ShodanGenericInput
    Fluent::Plugin.register_input('shodan_search', self)

    desc "The Shodan query to execute"
    config_param :query, :string
    desc "The maximum amount of pages to crawl. A 0 or negative value means to crawl all pages"
    config_param :max_pages, :integer, default: 1

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
