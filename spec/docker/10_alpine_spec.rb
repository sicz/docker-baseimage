# encoding: UTF-8
require "docker_helper"

if ENV["BASEIMAGE_NAME"] == "alpine" then

  describe "Operating system" do
    subject do
      os
    end
    it "is Alpine Linux #{ENV["DOCKER_TAG"]}" do
      expect(subject[:family]).to eq("alpine")
      expect(subject[:release]).to match(/^#{Regexp.escape(ENV["DOCKER_TAG"])}\./)
    end
  end

  describe "Package" do
    [
      "bash",
      "ca-certificates",
      "curl",
      "jq",
      "libressl",
      "runit",
      "su-exec",
      "tini",
    ].each do |package|
      context package do
        it "is installed" do
          expect(package(package)).to be_installed
        end
      end
    end
  end

end
