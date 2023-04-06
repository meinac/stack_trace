# frozen_string_literal: true

RSpec.describe StackTrace do
  class AbstractClass
    def self.abstract_method(num)
      Math.sqrt(num)
    end
  end

  class TestClass < AbstractClass
    def self.do_something
      abstract_method(4)
    end
  end

  describe '.trace' do
    let(:expected_trace) do
      {
        "spans" => [
          {
            "arguments" => {},
            "defined_class" => TestClass,
            "duration" => an_instance_of(Integer),
            "method_name" => :do_something,
            "receiver" => "TestClass",
            "return_value" => 2.0,
            "self_class" => "TestClass",
            "singleton" => true,
            "spans" => [
              {
                "arguments" => { :num => 4 },
                "defined_class" => AbstractClass,
                "duration" => an_instance_of(Integer),
                "method_name" => :abstract_method,
                "receiver" => "TestClass",
                "return_value" => 2.0,
                "self_class" => "TestClass",
                "singleton" => true,
                "spans" => [
                  {
                    "arguments" => { :req => nil },
                    "defined_class" => Math,
                    "duration" => an_instance_of(Integer),
                    "method_name" => :sqrt,
                    "receiver" => an_instance_of(String),
                    "return_value" => 2.0,
                    "self_class" => "Math",
                    "singleton" => true,
                    "spans" => []
                  }
                ]
              }
            ]
          }
        ]
      }
    end

    subject(:trace) { described_class.current }

    before do
      described_class.configure do |config|
        config.trace_ruby = true
        config.trace_c = true
        config.inspect_return_values = true
        config.inspect_arguments = true
      end

      described_class.trace { TestClass.do_something }
    end

    it { is_expected.to match(expected_trace) }

    describe 'calling the trace consecutively' do
      it 'runs as expected' do
        described_class.trace { TestClass.do_something }
        described_class.trace { TestClass.do_something }
      end
    end

    describe 'calling the current multiple times' do
      it 'returns the same result' do
        expect(described_class.current).to eq(described_class.current)
      end
    end

    describe 'nested trace calls' do
      it 'runs as expected' do
        described_class.trace do
          described_class.trace do
            TestClass.do_something
          end
        end
      end
    end
  end
end
