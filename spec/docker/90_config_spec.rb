# encoding: UTF-8
require "docker_helper"

describe "Docker entrypoint file" do
  context "/docker-entrypoint.sh" do
    it "is installed" do
      expect(file("/docker-entrypoint.sh")).to exist
      expect(file("/docker-entrypoint.sh")).to be_file
      expect(file("/docker-entrypoint.sh")).to be_executable
    end
  end
  [
    "/docker-entrypoint.d/01-lib-messages.sh",
    "/docker-entrypoint.d/02-lib-wait-for.sh",
    "/docker-entrypoint.d/10-default-command.sh",
    "/docker-entrypoint.d/20-docker-introspection.sh",
    "/docker-entrypoint.d/30-environment-certs.sh",
    "/docker-entrypoint.d/40-server-certs.sh",
    "/docker-entrypoint.d/90-exec-command.sh",
  ].each do |file|
    context file do
      it "is installed" do
        expect(file(file)).to exist
        expect(file(file)).to be_file
        expect(file(file)).to be_readable
      end
    end
  end
end

describe "Configuration file" do
  [
    "/etc/ssl/openssl.cnf",
  ].each do |file|
    context file do
      it "is installed" do
        expect(file(file)).to exist
        expect(file(file)).to be_file
        expect(file(file)).to be_readable
      end
    end
  end
end
