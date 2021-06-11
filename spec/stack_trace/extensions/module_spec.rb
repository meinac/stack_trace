# frozen-string-literal: true

RSpec.describe StackTrace::Extensions::Module do
  describe "#trace_method?" do
    let(:mod) { Class.new }

    subject(:trace_method?) { mod.trace_method?(:foo) }

    before do
      allow(StackTrace::Setup).to receive(:trackable?)
    end

    it "delegates the call to the `StackTrace::Setup` module" do
      trace_method?

      expect(StackTrace::Setup).to have_received(:trackable?).with(mod, :foo)
    end
  end

  describe "#stack_trace_id" do
    subject { mod.stack_trace_id }

    context "when the module has a name" do
      let(:mod) { Object.const_set("Foo", Class.new) }

      it { is_expected.to eq("Foo") }
    end

    context "when the module does not have a name" do
      let(:mod) { Class.new }

      before do
        allow(mod).to receive(:stack_trace_id).and_return("#<Class:0x...")
      end

      it { is_expected.to eq("#<Class:0x...") }
    end
  end
end
