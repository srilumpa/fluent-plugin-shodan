require 'test/unit'
require 'fluent/env'
require 'fluent/test'
require 'fluent/test/driver/input'
require 'fluent/test/helpers'
require "fluent/plugin/in_shodan_alert"

class ShodanAlertInputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  API_KEY = ENV['SHODAN_TEST_API_KEY']

  def setup
    Fluent::Test.setup
  end

  sub_test_case 'Configuration' do
    test 'is invalid without API key' do
      assert_raise Fluent::ConfigError do
        create_driver(%[])
      end
    end
    test 'is invalid if the API key is invalid' do
      assert_raise Fluent::ConfigError do
        create_driver(%[
          api_key 1234567890AZERTYUIOP
        ])
      end
    end
  end

  sub_test_case 'Plugin emission' do
  end

  private

  CONFIG = %[
    api_key #{API_KEY}
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::ShodanAlert).configure(conf)
  end
end
