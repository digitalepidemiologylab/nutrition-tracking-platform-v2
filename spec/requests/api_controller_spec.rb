# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ApiController) do
  let(:user) { create(:user) }
  let(:body) { JSON.parse(response.body) }

  before do
    stub_const("Foo", Class.new)

    tests_controller_class = Class.new(described_class) do
      skip_after_action :verify_authorized

      def custom
        Foo.new
        render plain: "custom called"
      end

      def custom_with_include_directive
        Foo.new
        permitted_include_directive(Foo, params[:include])
        render plain: "custom called"
      end

      def pundit_user
        current_api_v2_user
      end
    end
    stub_const("TestsController", tests_controller_class)

    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      get "/custom", to: "tests#custom"
      get "/custom_with_include_directive", to: "tests#custom_with_include_directive"
    end

    api_sign_in(user)
  end

  after { Rails.application.reload_routes! }

  describe "#permitted_include_directive" do
    before do
      foo_policy_class = Class.new do
        def initialize(user, record)
          @user = user
          @record = record
        end

        def permitted_includes
          %w[model1 model2]
        end
      end
      stub_const("FooPolicy", foo_policy_class)
    end

    context "when include param is nil" do
      it do
        get custom_with_include_directive_path, headers: auth_params
        expect(response).to have_http_status(:success)
      end
    end

    context "when include param is valid" do
      let(:params) { {include: "model1,model2"} }

      it do
        get custom_with_include_directive_path, params: params, headers: auth_params
        expect(response).to have_http_status(:success)
      end
    end

    context "when include param is not valid" do
      let(:params) { {include: "model2,model3,model4"} }

      it do
        get custom_with_include_directive_path, params: params, headers: auth_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(body).to eq(
          {
            "errors" => [
              {
                "detail" => "Bad include param (model3, model4)",
                "title" => "ApiController::BadIncludeParam"
              }
            ], "jsonapi" => {"version" => "1.0"}
          }
        )
      end
    end
  end

  describe "#check_app_version" do
    context "when user agent is missing" do
      let(:user_agent_header) { {"user-agent": nil} }

      it do
        get custom_path, headers: auth_params.merge(user_agent_header)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user agent has valid version" do
      let(:user_agent_header) { {"user-agent": "MyFoodRepo/3.0.0 (iOS 16.1; build:131)"} }

      it do
        get custom_path, headers: auth_params.merge(user_agent_header)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user agent has invalid version" do
      let(:user_agent_header) { {"user-agent": "MyFoodRepo/2.9.9 (iOS 16.1; build:131)"} }

      it do
        get custom_path, headers: auth_params.merge(user_agent_header)
        expect(response).to have_http_status(:upgrade_required)
        expect(body).to eq(
          {
            "errors" => [
              {
                "detail" => "Mobile app upgrade required",
                "title" => "UpgradeRequired",
                "code" => "mobile_app_upgrade_required"
              }
            ], "jsonapi" => {"version" => "1.0"}
          }
        )
      end
    end
  end

  describe "when success" do
    it {
      get custom_path, headers: auth_params
      expect(response).to have_http_status(:success)
    }
  end

  describe "when Exception" do
    let(:logger) { instance_double(ActiveSupport::Logger) }

    before do
      allow(logger).to receive(:info) # required for the request log
      allow(logger).to receive(:error)
      allow(Rails).to receive(:logger).with(no_args).and_return(logger)
      allow(Sentry).to receive(:capture_exception)
      allow(Foo).to receive(:new).and_raise(StandardError, "standard error")
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:server_error)
      expect(body).to eq(
        {"errors" => [{"detail" => "Internal server error", "title" => "StandardError"}], "jsonapi" => {"version" => "1.0"}}
      )
      expect(logger).to have_received(:error).with("standard error")
      expect(Sentry).to have_received(:capture_exception).with(StandardError)
    }
  end

  describe "when ApiController::BadIncludeParam" do
    before do
      allow(Foo).to receive(:new).and_raise(ApiController::BadIncludeParam, "bad include param")
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:unprocessable_entity)
      expect(body).to eq(
        {"errors" => [{"detail" => "bad include param", "title" => "ApiController::BadIncludeParam"}], "jsonapi" => {"version" => "1.0"}}
      )
    }
  end

  describe "when BaseQuery::BadFilterParam" do
    before do
      allow(Foo).to receive(:new).and_raise(BaseQuery::BadFilterParam, "bad filter param")
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:unprocessable_entity)
      expect(body).to eq(
        {"errors" => [{"detail" => "bad filter param", "title" => "BaseQuery::BadFilterParam"}], "jsonapi" => {"version" => "1.0"}}
      )
    }
  end

  describe "when ActionController::ParameterMissing" do
    before do
      allow(Foo).to receive(:new).and_raise(ActionController::ParameterMissing, "parameter missing")
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:unprocessable_entity)
      expect(body).to eq(
        {"errors" => [{"detail" => "param is missing or the value is empty: parameter missing", "title" => "ActionController::ParameterMissing"}], "jsonapi" => {"version" => "1.0"}}
      )
    }
  end

  describe "when Pundit::NotAuthorizedError" do
    before do
      allow(Foo).to receive(:new).and_raise(Pundit::NotAuthorizedError, "forbidden")
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:forbidden)
      expect(body).to eq(
        {"errors" => [{"detail" => "forbidden", "title" => "Pundit::NotAuthorizedError"}], "jsonapi" => {"version" => "1.0"}}
      )
    }
  end

  describe "when ActiveRecord::RecordNotFound" do
    before do
      allow(Foo).to receive(:new).and_raise(ActiveRecord::RecordNotFound.new("ididid", "Food", "id"), "not found")
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:not_found)
      expect(body).to eq(
        {"errors" => [{"detail" => "Food not found", "title" => "ActiveRecord::RecordNotFound"}], "jsonapi" => {"version" => "1.0"}}
      )
    }
  end

  describe "when ActiveRecord::RecordNotUnique" do
    before do
      allow(Foo).to receive(:new).and_raise(ActiveRecord::RecordNotUnique, "not unique")
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:conflict)
      expect(body).to eq(
        {
          "errors" => [
            {
              "detail" => "Record not unique",
              "title" => "ActiveRecord::RecordNotUnique",
              "code" => "record_not_unique"
            }
          ],
          "jsonapi" => {"version" => "1.0"}
        }
      )
    }
  end

  describe "when Pagy::OverflowError" do
    before do
      allow(Foo).to receive(:new).and_raise(Pagy::OverflowError.new("1", "2", "3", "4"))
      get custom_path, headers: auth_params
    end

    it {
      expect(response).to have_http_status(:not_found)
      expect(body).to eq(
        {"errors" => [{"detail" => "expected :2 3; got \"4\"", "title" => "Pagy::OverflowError"}], "jsonapi" => {"version" => "1.0"}}
      )
    }
  end
end
