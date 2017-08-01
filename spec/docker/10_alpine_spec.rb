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
    @packages = [
      "bash",
      "ca-certificates",
      "curl",
      "jq",
      "libressl",
      "runit",
      "su-exec",
      "tini",
    ]

    if ENV["DOCKER_NAME"] == "dockerspec" then
      @packages += [
        "git",
        "make",
        "openssh-client",
        "ruby",
        "ruby-io-console",
        "ruby-irb",
        "ruby-rdoc",
      ]
    end

    @packages.each do |package|
      context package do
        it "is installed" do
          expect(package(package)).to be_installed
        end
      end
    end
  end

end

if ENV["DOCKER_NAME"] == "dockerspec" then
  describe "Command" do
    [
      "/usr/bin/docker",
      "/usr/bin/docker-compose",
      "/usr/bin/rspec"
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

  describe "Ruby gem" do
    [
      "docker-api",
      "rspec",
      "serverspec",
    ].each do |package|
      context package do
        it "is installed" do
          expect(package(package)).to be_installed.by('gem')
        end
      end
    end
  end
end
