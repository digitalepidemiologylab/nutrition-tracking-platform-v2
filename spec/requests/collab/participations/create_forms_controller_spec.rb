# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Participations::CreateFormsController) do
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let(:cohort) { create(:cohort) }

  before { sign_in(collaborator_admin) }

  describe "#create" do
    context "with turbo_stream format" do
      let(:request) do
        post(collab_cohort_participations_create_form_path(cohort), params: params, headers: turbo_stream_headers)
      end

      context "when successful" do
        let(:params) { {participations_create_form: {number: 2}} }

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"update\"")
          expect(response.body).not_to match("Number must be greater than or equal to 1")
        end
      end

      context "when failed" do
        let(:params) { {participations_create_form: {number: -2}} }

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"update\"")
          expect(response.body).to match("Number must be greater than or equal to 1")
        end
      end
    end

    context "with html format" do
      let(:request) do
        post(collab_cohort_participations_create_form_path(cohort), params: params)
      end

      context "when successful" do
        let(:params) { {participations_create_form: {number: 2}} }

        it do
          request
          expect(response).to redirect_to(collab_cohort_participations_path(cohort))
        end
      end

      context "when failed" do
        let(:params) { {participations_create_form: {number: -2}} }

        it do
          request
          expect(response.body)
            .to match("<h1 class=\"text-2xl font-semibold text-gray-800\">Participations</h1>")
            .and(match("Number must be greater than or equal to 1"))
        end
      end
    end
  end
end
