# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stack_trace/version"

Gem::Specification.new do |spec|
  spec.name          = "stack_trace"
  spec.version       = StackTrace::VERSION
  spec.authors       = ["Mehmet Emin INAC"]
  spec.email         = ["mehmetemininac@gmail.com"]

  spec.summary       = "Tracks the execution of methods configured"
  spec.description   = "This library tracks the execution of methods, their arguments, return values etc."
  spec.homepage      = "https://github.com/meinac/stack_trace"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.extensions    = %w[ext/stack_trace/extconf.rb]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.13.0"
end
