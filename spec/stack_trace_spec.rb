# frozen-string-literal: true

RSpec.describe StackTrace do
  it "has a version number" do
    expect(StackTrace::VERSION).not_to be nil
  end
end
