# frozen_string_literal: true

require "rails_helper"

describe(Collab::UsersController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let(:cohort) { create(:cohort) }
  let(:participation) { create(:participation, cohort: cohort) }
  let(:query) { instance_double(UsersQuery) }
  let!(:user) { participation.user }

  before { sign_in(collaborator) }

  describe "#index" do
    before do
      allow(query).to receive(:query).and_return(User.all)
      allow(UsersQuery).to receive(:new).and_return(query)
    end

    it do
      get collab_users_path
      expect(response).to have_http_status(:success)
      expect(query).to have_received(:query).once
    end
  end

  describe "#show" do
    it do
      get(collab_user_path(user))
      expect(response).to have_http_status(:success)
    end
  end

  describe "#destroy" do
    let!(:user) { create(:user) }
    let(:request) { delete(collab_user_path(user)) }
    let(:destroy_service) { instance_double(Users::DestroyService) }

    before do
      allow(Users::DestroyService).to receive(:new).and_return(destroy_service)
    end

    context "when successful" do
      before do
        allow(destroy_service).to receive(:call).and_return(true)
      end

      it do
        request
        expect(response).to redirect_to(collab_users_path)
        expect(flash[:notice]).to eq("User deleted successfully")
        expect(destroy_service).to have_received(:call).once
      end
    end

    context "when unsuccessful" do
      before do
        allow(destroy_service).to receive_messages(call: false, errors: ActiveModel::Errors.new(described_class.new).tap { |e|
                                                                          e.add(:base, "Error message")
                                                                        })
      end

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(user.email)
        expect(flash.now[:alert]).to eq("User could not be deleted: Error message")
        expect(destroy_service).to have_received(:call).once
      end
    end
  end
end
