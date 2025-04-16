# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CommentTemplatePolicy) do
  let(:collaborator) { create(:collaborator) }
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:comment_template) { create(:comment_template, :valid) }

  permissions :index?, :show?, :new?, :create?, :edit?, :update? do
    it do
      expect(described_class).not_to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).not_to permit(collaborator, comment_template)
      expect(described_class).to permit(collaborator_admin, comment_template)
    end
  end

  permissions :destroy? do
    it do
      expect(described_class).not_to permit(collaborator, comment_template)
      expect(described_class).to permit(collaborator_admin, comment_template)
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(collaborator_admin, comment_template).permitted_attributes)
        .to contain_exactly(:title_de, :title_en, :title_fr, :message_de, :message_en, :message_fr)
    end
  end

  describe Collab::CommentTemplatePolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(collaborator_admin, CommentTemplate).resolve)
          .to contain_exactly(comment_template)
      end
    end
  end
end
