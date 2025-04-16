# frozen_string_literal: true

require "rails_helper"

describe(Seeds::S3SeedImportService) do
  let(:importer) do
    described_class.new(
      collection_name: "foods",
      item_hash_lambda: ->(row) { },
      items_import_lambda: ->(items) { }
    )
  end

  let(:s3_client) { Aws::S3::Client.new(stub_responses: true) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
  end

  describe "#call" do
    context "when file doesn't exist on S3" do
      before { s3_client.stub_responses(:get_object, "NoSuchKey") }

      it { expect { importer.call }.to raise_error(Aws::S3::Errors::NoSuchKey) }
    end

    context "when file exists on S3 and is invalid" do
      before do
        s3_client.stub_responses(
          :get_object,
          {body: File.read("spec/support/data/myfoodrepo1_export/invalid_zip.zip")}
        )
      end

      it { expect { importer.call }.to raise_error(Zip::Error) }
    end

    context "when file exists on S3 and is valid" do
      before do
        s3_client.stub_responses(
          :get_object,
          {body: File.read("spec/support/data/myfoodrepo1_export/subset_foods.zip")}
        )
      end

      it { expect { importer.call }.not_to raise_error }
    end
  end
end
