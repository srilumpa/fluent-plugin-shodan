require 'fluent/plugin/input'
require_relative 'shodan.rb'

module Fluent::Plugin
  class ShodanSearch < ShodanGenericInput
    Fluent::Plugin.register_input('shodan_search', self)

    config_param :query, :string

    private

    def run
      es = Fluent::MultiEventStream.new
      es_time = Fluent::EventTime.now
      result = @client.host_search(@query)
      result['matches'].each do |rec|
        es.add es_time, rec
      end
      router.emit_stream(@tag, es)
    rescue RuntimeError => re
    rescue => exception
      log.error "Error executing Shodan query", error: exception
      router.emit_error_event(@tag, Fluent::EventTime.now, {}, exception)
    end
  end
end
