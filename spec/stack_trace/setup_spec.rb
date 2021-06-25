# frozen-string-literal: true

class BaseMod; def foo; end; end

class UnFrozenTestMod < BaseMod; def bar; end; end

class FrozenTestMod < BaseMod; def bar; end; end.freeze

RSpec.describe StackTrace::Setup do
  describe ".trackable?" do
    let(:method_name) { :foo }

    subject { described_class.trackable?(mod, method_name) }

    before do
      StackTrace.configuration.modules = modules_config
    end

    shared_examples_for "module config for" do |config_key|
      let(:modules_config) { { config_key => module_config } }

      before do
        StackTrace::Setup.store.clear
      end

      context "when none of the methods of the module are trackable" do
        let(:module_config) { { instance_methods: false } }

        it { is_expected.to be_falsey }
      end

      context "when the method configuration is symbol" do
        context "when all the methods of the module is trackable" do
          let(:module_config) { { instance_methods: :all } }

          it { is_expected.to be_truthy }
        end

        context "when configuration is `:skip_inherited`" do
          let(:module_config) { { instance_methods: :skip_inherited } }

          context "when the given method is inherited" do
            it { is_expected.to be_falsey }
          end

          context "when the given method is not inherited" do
            let(:method_name) { :bar }

            it { is_expected.to be_truthy }
          end
        end
      end

      context "when the method configuration is array" do
        let(:module_config) { { instance_methods: [:foo] } }

        context "when the given method is not in the array of methods" do
          it { is_expected.to be_truthy }
        end

        context "when the given method is in the array of methods" do
          let(:method_name) { :bar }

          it { is_expected.to be_falsey }
        end
      end

      context "when the method configuration is regex" do
        let(:module_config) { { instance_methods: /fo.*/ } }

        context "when the given method matches with the configuration regex" do
          it { is_expected.to be_truthy }
        end

        context "when the given method does not match with the configuration regex" do
          let(:method_name) { :bar }

          it { is_expected.to be_falsey }
        end
      end
    end

    context "when the given module is frozen" do
      let(:mod) { FrozenTestMod }

      context "when the given module is not trackable" do
        let(:modules_config) { {} }

        it { is_expected.to be_falsey }
      end

      it_behaves_like "module config for", FrozenTestMod
      it_behaves_like "module config for", /frozentestmod/i
      it_behaves_like "module config for", { inherits: BaseMod }
      it_behaves_like "module config for", { path: "spec/stack_trace/setup_spec.rb" }
      it_behaves_like "module config for", [FrozenTestMod]
    end

    context "when the given module is not frozen" do
      let(:mod) { UnFrozenTestMod }

      context "when the given module is not trackable" do
        let(:modules_config) { {} }

        it { is_expected.to be_falsey }
      end

      it_behaves_like "module config for", UnFrozenTestMod
      it_behaves_like "module config for", /unfrozentestmod/i
      it_behaves_like "module config for", { inherits: BaseMod }
      it_behaves_like "module config for", { path: "spec/stack_trace/setup_spec.rb" }
      it_behaves_like "module config for", [UnFrozenTestMod]
    end
  end
end
