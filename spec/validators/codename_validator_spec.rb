# frozen_string_literal: true

require "rails_helper"

RSpec.describe(CodenameValidator) do
  let(:cname_bearer_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :cname

      validates :cname, codename: true

      def self.name
        "CnameBearer"
      end
    end
  end
  let(:instance) { cname_bearer_class.new }

  context "when cname is valid" do
    before { instance.cname = "valid_cname" }

    it { expect(instance).to be_valid }
  end

  context "when cname is not valid" do
    context "when it contains uppercase chars" do
      before { instance.cname = "INvalid_cname" }

      it do
        expect(instance).not_to be_valid
        expect(instance.errors.full_messages)
          .to include("Cname must only contain “letters, numbers, underscores, and ampersands”")
      end
    end

    context "when it contains space" do
      before { instance.cname = "invalid cname" }

      it do
        expect(instance).not_to be_valid
        expect(instance.errors.full_messages)
          .to include("Cname must only contain “letters, numbers, underscores, and ampersands”")
      end
    end

    context "when it contains invalid chars" do
      before { instance.cname = "invalid$$cname" }

      it do
        expect(instance).not_to be_valid
        expect(instance.errors.full_messages)
          .to include("Cname must only contain “letters, numbers, underscores, and ampersands”")
      end
    end
  end
end
