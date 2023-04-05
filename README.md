# StackTrace

Creates call stack trace for given block of Ruby code.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add stack_trace

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install stack_trace

## Usage

```ruby
StackTrace.trace do
  Foo.bar
end

StackTrace.current # => Returns a Hash that contains all the method calls and exception information.
```

## Configuration

```ruby
StackTrace.configure do |config|
  config.trace_ruby = true
  config.trace_c = true
  config.inspect_return_values = true # Default `false` for performance reasons
  config.inspect_arguments = true # Default `false` for performance reasons

  config.check_proc = -> (klass_name, method_name) do # If you want to limit the tracing for a set of classes
    klass_name == "Bar"
  end
end
```
