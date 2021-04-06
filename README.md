# StackTrace

adasStackTrace traces method calls in your application which can give you an overview about how your application works, which objects depends on which ones and what are the bottlenecks.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stack_trace'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stack_trace

## Terminology

Before we jump into details we should talk about the two important terms that you should grasp first to understand the tracing output, which are `trace` and `span`.

#### Trace

Trace is an object which encapsulates the whole process. Whenever you start tracing, there will be a `trace` object associated which has a unique identifier(uuid v4) and holds all the `spans`.

#### Span

Span holds the information about the actual **unit of work**. StackTrace will create a new span for each method call if it's been told to do so by the configuration. Spans hold all the information that you need about the method calls like the time taken, arguments etc. as well as the child spans if the method calls othre methods.
You will see detailed information about the spans in the `Getting tracing information` chapter.

## Usage

Using StackTrace gem is pretty straight forward. First you should configure it to set which modules/classes and which methods should be traced and then you can start tracing the execution of your code with `StackTrace::trace` method.

#### Configuration

With the below configuration, StackTrace will trace all the methods of **Foo** `module/class` and only the `zoo` method of **Bar** `module/class`.

```ruby
StackTrace.configure do |config|
  config.enabled = true
  config.modules = {
      Foo => {
        instance_methods: :all,
        class_methods: :all
      },
      Bar => { instance_methods: [:zoo] }
  }
end
```

`instance_methods` and `class_methods` can be configured with the following values;

- `:all` to trace all methods
- `:skip_inherited` to trace only the methods defined in module/class
- Array of symbols to specify method names one by one
- Regexp to trace all methods matching the given regular expression

Also the keys for `modules` hash can have the following values;

- `Class/Module` to trace methods of given value
- An array of `Class/Module` to trace methods of all given values
- Regular expression to trace methods of all matching modules or classes
- { path: "..." } to trace all the modules/classes loaded from a specific path
- { inherits: Class } to trace methods of all classes inherited from base class.

Here are the example usages;

```ruby
StackTrace.configure do |config|
  config.enabled = true
  config.modules = {
      Foo => { instance_methods: :skip_inherited },
      [Too, Joo] => { class_methods: :all }
      /Ba.*/ => { instance_methods: :all },
      { inherits: Zoo } => { instance_methods: [:foo, :bar, :zoo] },
      { path: Rails.root.join('app', 'models').to_s => { instance_methods: :all }
  }
end
```

##### Other configuration keys

Here are the other configuration keys to change the behavior of `StackTrace`;

```ruby
StackTrace.configure do |config|
  config.ruby_calls = false # default `true`
  config.c_calls = false # default `true`
  config.trace_parameters = true # default `false`
  config.trace_memory = true # default `false`
  config.output_dir = '....' # default `__FILE__/stack_trace/`
end
```

#### Tracing

After configuring the StackTrace, you can call `StackTrace::trace` method to create a tracing information, like so;

```ruby
  StackTrace.trace { Math.sqrt(4) } # => #<StackTrace::Trace:0x00007f97b29643c0...
```

#### Getting tracing information

Currently StackTrace gem provides tracing information as a Ruby `Hash` object. You can use `StackTrace::Trace#as_json` method to receive the `Hash` for the current trace, like so;

```ruby
  trace = StackTrace.trace { 1 + 1 }
  trace.as_json # => # { .... }
```

#### What does StackTrace collect?

The `Hash` object returned by `StackTrace::Trace::as_json` method has the following structure;

* **uuid**: This is a UUID V4 value to identify the trace.
* **spans**: This is an array of spans which has the following structure;
  * **receiver**: The identifier for the receiver object.
  * **method_name**: The name of the method which this span is created for.
  * **arguments**: Arguments received by the method.
  * **value**: The return value of the method.
  * **exception**: The exception information if an exception is raised in this method. This attribute has the following child attributes:
    * **message**: The error message(`error.message`).
    * **backtrace**: The backtrace information of the excption as an array of strings.
  * **time**: How long the execution of this unit of work took.
  * **spans**: Child spans of the span.

Imagine you have the following configuration and class;

```ruby
class Greeting
  def hello(first_name, last_name)
    "Hello, #{capitalize(first_name)} #{capitalize(last_name)}"
  end

  def capitalize(string)
    string.capitalize
  end
end

StackTrace.configure do |config|
  config.enabled = true
  config.modules = {
    Greeting => { instance_methods: :all }
  }
end
```

The the execution of the following code leads to below return object from `StackTrace::Trace.as_json` method;

```ruby
StackTrace.trace do
  Greeting.new.hello("john", "doe")
  result = StackTrace::Trace.as_json
end

result == {
    uuid: "12e2a347-8d5a-4d1d-a5ad-efe012ffcdf9",
    spans: [
        {
            receiver: "Greeting#123124312",
            method_name: "initialize",
            arguments: {},
            value: nil,
            exception: nil,
            time: "10.927719116210938 µs",
            spans: []
        },
        {
            receiver: "Greeting#123124312",
            method_name: "hello",
            arguments: {
                first_name: "john",
                last_name: "doe"
            },
            value: "Hello, John Doe",
            exception: nil,
            time: "20.831909134113330 µs",
            spans: [
                {
                    receiver: "Greeting#123124312",
                    method_name: "capitalize",
                    arguments: {
                        string: "john"
                    },
                    value: "John",
                    exception: nil,
                    time: "6.198883056640625 µs",
                    spans: []
                },
                {
                    receiver: "Greeting#123124312",
                    method_name: "capitalize",
                    arguments: {
                        string: "doe"
                    },
                    value: "Doe",
                    exception: nil,
                    time: "4.291534423828125 µs",
                    spans: []
                }
            ]
        }
    ]
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/meinac/stack_trace.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
