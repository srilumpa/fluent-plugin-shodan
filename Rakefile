#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

desc 'Run test_unit based test'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
