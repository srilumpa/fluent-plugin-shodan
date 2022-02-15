require 'fluent/plugin/input'
require 'shodanz'

module Fluent::Plugin
  class ShodanSearch < Input
    Fluent::Plugin.register_input('shodan_search', self)

    helpers :timer

    SUPPORTED_FILTERS = [
      'asn','city','country','cpe','device','geo','has_ipv6','has_screenshot',
      'has_ssl','has_vuln','hash','hostname','ip','isp','link','net','org','os',
      'port','postal','product','region','scan','shodan.module','state',
      'version','screenshot.label','cloud.provider','cloud.region',
      'cloud.service','http.component','http.component_category',
      'http.favicon.hash','http.html','http.html_hash','http.robots_hash',
      'http.securitytxt','http.status','http.title','http.waf','bitcoin.ip',
      'bitcoin.ip_count','bitcoin.port','bitcoin.version','snmp.contact',
      'snmp.location','snmp.name','ssl','ssl.alpn','ssl.cert.alg',
      'ssl.cert.expired','ssl.cert.extension','ssl.cert.fingerprint',
      'ssl.cert.issuer.cn','ssl.cert.pubkey.bits','ssl.cert.pubkey.type',
      'ssl.cert.serial','ssl.cert.subject.cn','ssl.chain_count',
      'ssl.cipher.bits','ssl.cipher.name','ssl.cipher.version','ssl.ja3s',
      'ssl.jarm','ssl.version','ntp.ip','ntp.ip_count','ntp.more','ntp.port',
      'telnet.do','telnet.dont','telnet.option','telnet.will','telnet.wont',
      'ssh.hassh','ssh.type', 'tag', 'vuln'
    ]

    desc "The API key to connect to the Shodan API."
    config_param :api_key, :string, secret: true
    desc "The interval time between running queries."
    config_param :interval, :time, default: 3600
    desc "The tag to apply to each shodan entries."
    config_param :tag, :string, default: nil
    desc "The Shodan query to execute."
    config_param :query, :string, default: ''
    desc "The maximum amount of pages to crawl. A 0 or negative value means to crawl all pages."
    config_param :max_pages, :integer, default: 1
    desc "Search filters configuration."
    config_section :filter, param_name: 'filters', required: false, multi: true do
      desc "Name of the filter. See https://www.shodan.io/search/filters for a list of supported filters"
      config_param :name, :enum, list: (SUPPORTED_FILTERS + SUPPORTED_FILTERS.map {|filter| "-#{filter}"}).map { |filter| filter.to_sym }
      desc "Value to be given to the filter"
      config_param :value, :string
    end

    def configure(conf)
      super

      @client = Shodanz.client.new(key: @api_key)
      begin
        log.info "Shodan client properly registered", client_info: @client.info
      rescue RuntimeError => exception
        raise Fluent::ConfigError.new "Invalid Shodan API key"
      end

      raise Fluent::ConfigError.new("At least a query or one filter should be configured") if @query.empty? and @filters.empty?

      @search_filters = {}
      @filters.each do |filter|
        @search_filters[filter.name] = filter.value
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
      opts = @search_filters.merge({page: 0})
      read_entries = 0
      loop do
        opts[:page] += 1
        log.trace query: @query, opts: opts
        result = @client.host_search(@query.dup, **opts)
        result['matches'].each do |rec|
          router.emit(@tag, es_time, rec)
        end
        read_entries += result['matches'].length
        break if (@max_pages >= 0 && opts[:page] >= @max_pages) || read_entries >= result['total']
      end
      log.debug "Shodan search ending", query: @query, filters: @search_filters, total_read: read_entries
    rescue RuntimeError => re
      log.error "Unable to execute Shodan query", query: @query, filters: @search_filters, page: current_page, error: re
    rescue => exception
      log.error "Error executing Shodan query", error: exception
    end
  end
end
