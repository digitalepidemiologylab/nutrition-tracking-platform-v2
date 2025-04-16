# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Compression") do
  context "when the browser supports compression" do
    before { get root_path, headers: {"Accept-Encoding" => encoding} }

    context "when the browser accepts gzip encoding" do
      let(:encoding) { "gzip" }

      it { expect(response.headers).to have_key("Content-Encoding") }
    end

    context "when the browser accepts deflate,gzip encoding" do
      let(:encoding) { "deflate,gzip" }

      it { expect(response.headers).to have_key("Content-Encoding") }
    end

    context "when the browser accepts gzip,deflate encoding" do
      let(:encoding) { "gzip,deflate" }

      it { expect(response.headers).to have_key("Content-Encoding") }
    end
  end

  context "when the browser do not supports compression" do
    before { get root_path }

    it { expect(response.headers).not_to have_key("Content-Encoding") }
  end
end
