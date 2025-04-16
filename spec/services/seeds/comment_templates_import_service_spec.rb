# frozen_string_literal: true

require "rails_helper"

describe(Seeds::CommentTemplatesImportService) do
  describe "#call" do
    let(:importer) { described_class.new }
    let(:s3_client) {
      Aws::S3::Client.new(
        stub_responses: {
          get_object: {body: File.read("spec/support/data/myfoodrepo1_export/annotation_questions.zip")}
        }
      )
    }

    before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

    it do
      expect { importer.call }.to change(CommentTemplate, :count).by(17)
        .and(change(CommentTemplate::Translation, :count).by(51))
    end
  end
end
