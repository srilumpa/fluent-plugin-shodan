require "helper"
require "fluent/plugin/in_shodan_search.rb"

class ShodanSearchInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::ShodanSearch).configure(conf)
  end
end
