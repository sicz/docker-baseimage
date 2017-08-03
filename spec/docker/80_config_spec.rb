require "docker_helper"

describe "Docker entrypoint file" do
  context "/docker-entrypoint.sh" do
    it "is installed" do
      expect(file(subject)).to exist
      expect(file(subject)).to be_file
      expect(file(subject)).to be_executable
      expect(file(subject).sha256sum).to eq(
        Digest::SHA256.file("config/#{subject}").to_s
      )
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
        expect(file(subject)).to exist
        expect(file(subject)).to be_file
        expect(file(subject)).to be_readable
        expect(file(subject).sha256sum).to eq(
          Digest::SHA256.file("config/#{subject}").to_s
        )
      end
    end
  end
end

describe "Configuration file" do
  [
    "/etc/bashrc",
    "/etc/inputrc",
    "/etc/profile",
    "/etc/ssl/openssl.cnf",
    "/root/.bash_logout",
    "/root/.bash_profile",
    "/root/.bashrc",
  ].each do |file|
    context file do
      it "is installed" do
        expect(file(subject)).to exist
        expect(file(subject)).to be_file
        expect(file(subject)).to be_readable
        expect(file(subject).sha256sum).to eq(
          Digest::SHA256.file("config/#{subject}").to_s
        )
      end
    end
  end
end
