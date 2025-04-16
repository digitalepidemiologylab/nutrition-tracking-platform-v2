# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define(:validate_codename_of) do |attribute|
  match do |actual|
    codename = actual.send(attribute)
    allow(CodenameValidator).to receive(:valid?).with(codename)
    actual.validate
    expect(CodenameValidator).to have_received(:valid?).with(codename)
    true
  end
end
