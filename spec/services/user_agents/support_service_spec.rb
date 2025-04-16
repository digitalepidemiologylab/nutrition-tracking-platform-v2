# frozen_string_literal: true

require "rails_helper"

describe UserAgents::SupportService do
  describe "#call" do
    let(:service) { described_class.new(user_agent: user_agent) }

    context "when user agent is not MyFoodRepo" do
      let(:user_agent) { "Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Mobile Safari/537.36" }

      it { expect(service.call).to be_truthy }
    end

    context "when user agent is MyFoodRepo" do
      context "when platform is iOS" do
        context "when version is supported" do
          let(:user_agent) { "MyFoodRepo/3.0.0 (iOS 16.1; build:131)" }

          it { expect(service.call).to be_truthy }
        end

        context "when version is not supported" do
          let(:user_agent) { "MyFoodRepo/2.9.9 (iOS 16.1; build:131)" }

          it { expect(service.call).to be_falsy }
        end

        context "when version number is malformed" do
          let(:user_agent) { "MyFoodRepo/malformed (iOS 16.1; build:131)" }

          it { expect(service.call).to be_falsy }
        end

        context "when comment is missing" do
          let(:user_agent) { "MyFoodRepo/3.0.0" }

          it { expect(service.call).to be_falsy }
        end

        context "when default iOS header" do
          let(:user_agent) { "MyFoodRepo/1 CFNetwork/1399 Darwin/22.1.0" }

          it { expect(service.call).to be_falsy }
        end
      end

      context "when platform is Android" do
        context "when version is supported" do
          let(:user_agent) { "MyFoodRepo/3.0.0 (Android; build:131)" }

          it { expect(service.call).to be_truthy }
        end

        context "when version is not supported" do
          let(:user_agent) { "MyFoodRepo/2.9.9 (Android; build:131)" }

          it { expect(service.call).to be_falsy }
        end
      end
    end
  end
end
