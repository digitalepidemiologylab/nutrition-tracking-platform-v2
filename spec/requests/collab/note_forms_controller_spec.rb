# frozen_string_literal: true

require("rails_helper")

describe(Collab::NoteFormsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let(:notable) { create(:user) }

  before { sign_in(collaborator) }

  describe("#show") do
    it do
      get(collab_user_note_forms_path(notable), headers: turbo_stream_headers)
      expect(response).to have_http_status(:success)
    end
  end

  describe("#edit") do
    it do
      get(edit_collab_user_note_forms_path(notable), headers: turbo_stream_headers)
      expect(response).to have_http_status(:success)
    end
  end

  describe("#update") do
    let(:params) do
      {
        note_form: {
          note: "This is a note"
        }
      }
    end

    let(:request) do
      patch(collab_user_note_forms_path(notable), params: params, headers: turbo_stream_headers)
    end

    context "when successful" do
      it do
        expect { request }
          .to change { notable.reload.note }.to("This is a note")
        expect(response).to redirect_to(collab_user_note_forms_path(notable))
      end
    end

    context "when unsuccessful" do
      before do
        allow_any_instance_of(NoteForm).to receive(:save).and_return(false)
        allow_any_instance_of(NoteForm)
          .to receive(:errors)
          .and_return(ActiveModel::Errors.new(NoteForm.new(notable: notable)).tap { |e| e.add(:base, "note too long") })
      end

      it do
        expect { request }
          .not_to change { notable.reload.note }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match("note too long")
      end
    end
  end
end
