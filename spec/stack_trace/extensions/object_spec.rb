# frozen-string-literal: true

RSpec.describe StackTrace::Extensions::Object do
  describe "#stack_trace_id" do
    let(:object) { :foo }
    let(:id_in_hex) { format("0x%014x", (object.object_id << 1)) }

    subject { object.stack_trace_id }

    it { is_expected.to eq("#<Symbol:#{id_in_hex}>") }
  end
end
