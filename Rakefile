# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/extensiontask"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

Rake::ExtensionTask.new "stack_trace" do |ext|
  ext.lib_dir = "lib/stack_trace/ext"
end
