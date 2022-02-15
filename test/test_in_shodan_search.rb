require 'test/unit'
require 'fluent/env'
require 'fluent/test'
require 'fluent/test/driver/input'
require 'fluent/test/helpers'
require "fluent/plugin/in_shodan_search"

class ShodanSearchInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  API_KEY = ENV['SHODAN_TEST_API_KEY']
  CONFIG = %[
    api_key #{API_KEY}
    query 8.8.8.8
  ]

  private_constant :API_KEY
  private_constant :CONFIG

  def setup
    Fluent::Test.setup
  end

  sub_test_case 'Configuration' do
    test 'is invalid without API key' do
      assert_raise Fluent::ConfigError do
        create_driver(%[
          query 8.8.8.8
        ])
      end
    end
    test 'is invalid if the API key is invalid' do
      assert_raise Fluent::ConfigError do
        create_driver(%[
          api_key 1234567890AZERTYUIOP
          query 8.8.8.8
        ])
      end
    end
    test 'is invalid without a query or a filter' do
      assert_raise Fluent::ConfigError do
        create_driver(%[
          api_key #{API_KEY}
        ])
      end
    end
    test 'is invalid with an unsupported filter' do
      assert_raise Fluent::ConfigError do
        create_driver(%[
          api_key #{API_KEY}
          <filter>
            name some.dumb.filter
            value 42
          </filter>
        ])
      end
    end
    test 'query is set correctly' do
      d = create_driver
      assert_equal '8.8.8.8', d.instance.query
    end
    test 'is valid with one filter and no query' do
      assert_nothing_raised do
        d = create_driver(%[
          api_key #{API_KEY}
          <filter>
            name product
            value ssh
          </filter>
        ])
      end
    end
  end
  
  sub_test_case 'Plugin emission' do
    test 'with simple query' do
      expected_tag = 'test_shodan'
      d = create_driver(CONFIG + "\ninterval 5\ntag #{expected_tag}")
      d.run(expect_emits: 10, timeout: 30)
      events = d.events
      assert_not_empty(events)
      assert_all(events, "Events are not properly tagged") {|evt| expected_tag == evt[0]}
      assert_all(events, "Events do not have a '_shodan' key") {|evt| evt[2]['data'].downcase.include?('8.8.8.8')}
      assert_all(events, "Events do not have a '_shodan' key") {|evt| evt[2].has_key?('_shodan')}
    end

    test 'with a single filter' do
      config = %[
        api_key #{API_KEY}
        query ssh
        interval 5
        tag shodan_test
        <filter>
          name product
          value ssh
        </filter>
      ]
      d = create_driver(config)
      d.run(expect_emits: 10, timeout: 30)
      events = d.events
      assert_not_empty(events)
      assert_all(events) {|evt| evt[2]['product'].downcase.include?('ssh')}
    end

    test 'with multiple filters' do
      config = %[
        api_key #{API_KEY}
        query ssh
        interval 5
        tag shodan_test
        <filter>
          name product
          value ssh
        </filter>
        <filter>
          name -port
          value 22
        </filter>
      ]
      d = create_driver(config)
      d.run(expect_emits: 10, timeout: 30)
      events = d.events
      assert_not_empty(events)
      assert_all(events) {|evt| evt[2]['product'].downcase.include?('ssh')}
      assert_all(events) {|evt| evt[2]['port'] != 22}
    end

    test 'combine query and filters' do
      config = %[
        api_key #{API_KEY}
        query ssh
        interval 5
        tag shodan_test
        query plex
        <filter>
          name country
          value FR
        </filter>
        <filter>
          name -port
          value 32400
        </filter>
      ]
      d = create_driver(config)
      d.run(expect_emits: 10, timeout: 30)
      events = d.events
      assert_not_empty(events)
      assert_all(events) {|evt| evt[2]['data'].downcase.include?('plex')}
      assert_all(events) {|evt| evt[2]['location']['country_code'] == 'FR'}
      assert_all(events) {|evt| evt[2]['port'] != 32400}
    end
  end

  private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::ShodanSearch).configure(conf)
  end
end
