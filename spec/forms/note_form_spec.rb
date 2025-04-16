# frozen_string_literal: true

require "rails_helper"

describe(NoteForm) do
  let!(:notable) { create(:user) }
  let(:note_form) { described_class.new(notable: notable) }

  it do
    expect(note_form).to respond_to(:notable)
    expect(note_form).to respond_to(:note)
  end

  describe "#save(params)" do
    context "when params valid" do
      let(:params) { {note: "An internal note"} }

      it do
        expect { note_form.save(params) }
          .to(change { notable.reload.note }.to("An internal note"))
      end
    end

    context "when params invalid" do
      let(:params) { {note: Faker::Lorem.words(number: 40)} }

      it do
        expect { note_form.save(params) }
          .not_to(change { notable.reload.note }.from(nil))
        expect(note_form.errors.full_messages).to contain_exactly("User: note is too long (maximum is 280 characters)")
      end
    end

    context "when exception is raised" do
      let(:params) { {note: "An internal note"} }

      before do
        allow_any_instance_of(User).to receive(:save!).and_raise(StandardError, "Something went wrong")
      end

      it do
        expect { note_form.save(params) }
          .not_to(change { notable.reload.note }.from(nil))
        expect(note_form.errors.full_messages).to contain_exactly("Something went wrong")
      end
    end
  end
end
