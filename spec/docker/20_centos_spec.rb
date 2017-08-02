# encoding: UTF-8
require "docker_helper"

if ENV["BASEIMAGE_NAME"] == "centos" then

  describe "Operating system" do
    subject do
      os
    end
    it "is CentOS #{ENV["DOCKER_TAG"]}" do
      expect(subject[:family]).to eq("redhat")
      expect(subject[:release]).to match(/^#{Regexp.escape(ENV["DOCKER_TAG"])}\./)
    end
  end

  describe "Package" do
    [
      "bash",
      "ca-certificates",
      "curl",
      "less",
      "openssl",
      "which",
    ].each do |package|
      context package do
        it "is installed" do
          expect(package(package)).to be_installed
        end
      end
    end
  end

  describe "Command" do
    [
      "/usr/bin/jq",
      "/sbin/runit",
      "/sbin/runsvdir",
      "/sbin/su-exec",
      "/sbin/tini",
    ].each do |command|
      context command do
        it "is installed" do
          expect(file(command)).to exist
          expect(file(command)).to be_file
          expect(file(command)).to be_executable
        end
      end
    end
  end

end
