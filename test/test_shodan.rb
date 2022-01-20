require "helper"
require "fluent/plugin/shodan.rb"

class ShodanGenericInputInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::ShodanGenericInput).configure(conf)
  end
end
