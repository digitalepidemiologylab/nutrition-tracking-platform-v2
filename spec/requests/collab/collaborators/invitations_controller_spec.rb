# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Collaborators::InvitationsController) do
  let(:collaboration) { create(:collaboration, :manager) }
  let(:cohort) { collaboration.cohort }

  describe "#new" do
    before { sign_in(collaboration.collaborator) }

    it do
      get new_collaborator_invitation_path(cohort_id: cohort.id)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    before { sign_in(collaboration.collaborator) }

    let(:request) { post collaborator_invitation_path, params: params }

    context "with valid params" do
      let(:email) { "a_new_collaborator@myfoodrepo.org" }
      let(:params) do
        {
          collaborator:
          {
            email: email,
            collaborations_attributes: {"0": {cohort_id: cohort.id, role: "annotator"}}
          }
        }
      end

      context "when collaborator exists" do
        let!(:existing_collaborator) { create(:collaborator, email: email) }

        context "when collaboration exists" do
          let!(:existing_collaboration) do
            create(:collaboration, :annotator, collaborator: existing_collaborator, cohort: cohort)
          end

          it do
            expect { request }.to not_change(Collaborator, :count)
              .and(not_change { existing_collaborator.collaborations.count })
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when collaboration doesn't exists" do
          it do
            expect { request }.to not_change(Collaborator, :count)
              .and(change { existing_collaborator.collaborations.count }.by(1))
            expect(response).to redirect_to(collab_cohort_path(cohort))
          end
        end
      end

      context "when collaborator doesn't exists" do
        it do
          expect { request }.to change(Collaborator, :count).by(1)
          expect(response).to redirect_to(collab_cohort_path(cohort))

          new_collaboration = Collaborator.find_by(email: email).collaborations.sole
          expect(new_collaboration.role).to eq("annotator")
          expect(new_collaboration.cohort).to eq(cohort)
        end
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          collaborator:
          {
            email: "",
            collaborations_attributes: {"0": {cohort_id: cohort.id, role: "annotator"}}
          }
        }
      end

      it do
        expect { request }.to not_change(Collaborator, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#edit" do
    let(:new_collaborator) { Collaborator.invite!({email: "new_collaborator@myfoodrepo.org"}) }

    it do
      get accept_collaborator_invitation_path(invitation_token: new_collaborator.raw_invitation_token)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:new_collaborator) { Collaborator.invite!({email: "new_collaborator@myfoodrepo.org"}) }
    let(:request) { patch collaborator_invitation_path, params: params }

    context "with valid params" do
      let(:params) do
        {
          collaborator: {
            invitation_token: new_collaborator.raw_invitation_token,
            name: "A Name",
            password: "aPassword",
            password_confirmation: "aPassword"
          }
        }
      end

      it do
        request
        expect(response).to redirect_to(collab_profile_path)
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          collaborator: {
            invitation_token: new_collaborator.raw_invitation_token,
            name: "",
            password: "aPassword",
            password_confirmation: "aPassword"
          }
        }
      end

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#destroy" do
    let(:new_collaborator) { Collaborator.invite!({email: "new_collaborator@myfoodrepo.org", name: "Test Test"}) }

    it do
      get remove_collaborator_invitation_path(invitation_token: new_collaborator.raw_invitation_token)
      expect(response).to have_http_status(:not_found)
    end
  end
end
