require 'test/unit'
require 'fluent/env'
require 'fluent/test'
require 'fluent/test/driver/input'
require 'fluent/test/helpers'
require "fluent/plugin/in_shodan_search"

class ShodanSearchInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  API_KEY = ENV['SHODAN_TEST_API_KEY']

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
  end

  private

  CONFIG = %[
    api_key #{API_KEY}
    query 8.8.8.8
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::ShodanSearch).configure(conf)
  end
end
