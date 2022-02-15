# encoding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'fluent-plugin-shodan'
  s.version = '0.0.3'

  s.required_rubygems_version = Gem::Specification.new('>=0') if s.respond_to? :required_rubygems_version=
  s.authors = ['srilumpa']
  s.date = Time.new.strftime('%Y-%m-%d')
  s.email = 'marcandre.doll@gmail.com'
  s.license = 'Apache-2.0'
  s.homepage = 'https://github.com/srilumpa/fluent-plugin-shodan'
  s.summary = 'Fluentd plugin to extract data from Shodan'

  s.extra_rdoc_files = [
    'README.md'
  ]
  s.files = [
    'AUTHORS',
    'VERSION',
    'lib/fluent/plugin/in_shodan_alert.rb',
    'lib/fluent/plugin/in_shodan_search.rb'
  ]
  s.test_files = [
    'test/test_in_shodan_alert.rb',
    'test/test_in_shodan_search.rb'
  ]
  s.require_paths = ['lib']

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_runtime_dependency('fluentd', ['>= 0.12.0', '< 2'])
      s.add_runtime_dependency('shodanz', ['~> 2.0'])
      s.add_runtime_dependency('io-console')
    else
      s.add_dependency('fluentd', ['>= 0.12.0', '< 2'])
      s.add_dependency('shodanz', ['~> 2.0'])
      s.add_dependency('io-console')
    end
  else
    s.add_dependency('fluentd', ['>= 0.12.0', '< 2'])
    s.add_dependency('shodanz', ['~> 2.0'])
    s.add_dependency('io-console')
  end
  s.add_development_dependency 'bundler', '~> 2'
  s.add_development_dependency 'rake', '~> 13'
  s.add_development_dependency 'test-unit', '~> 3.5'
end
