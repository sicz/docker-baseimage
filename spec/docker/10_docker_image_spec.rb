require "docker_helper"

################################################################################

describe "Docker image", :test => :docker_image do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ##############################################################################

  # [command, version, args]
  commands = []

  # [file, mode, user, group, [expectations]]
  files = [
    ["/etc/bashrc",                                     644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/etc/inputrc",                                    644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/etc/profile",                                    644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/etc/ssl/openssl.cnf",                            644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/root/.bash_logout",                              644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/root/.bash_profile",                             644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.sh",                           755, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.d/01-lib-messages.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.d/02-lib-wait-for.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.d/10-default-command.sh",      644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.d/20-docker-introspection.sh", 644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.d/30-environment-certs.sh",    644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.d/40-server-certs.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
    ["/docker-entrypoint.d/90-exec-command.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
  ]

  # [package, version, installer]
  packages = []

  # [process, user, group, pid]
  processes = []

  ##############################################################################

  case ENV["BASE_IMAGE_NAME"]
  when "alpine"
    packages += [
      "bash",
      "ca-certificates",
      "curl",
      "jq",
      "libressl",
      "nmap-ncat",
      "runit",
      "su-exec",
      "tini",
    ]
    processes += [
      ["/sbin/tini",              "root", "root", 1],
    ]
  when "centos"
    commands += [
      "/usr/bin/jq",
      "/sbin/runit",
      "/sbin/runsvdir",
      "/sbin/su-exec",
      "/sbin/tini",
    ]
    packages += [
      "bash",
      "bind-utils",
      "ca-certificates",
      "curl",
      "less",
      "net-tools",
      "nmap-ncat",
      "openssl",
      "which",
    ]
    processes += [
      ["tini",                    "root", "root", 1],
    ]
  else
    raise "Unknown base image #{ENV["BASE_IMAGE_NAME"]}"
  end

  ##############################################################################

  case ENV["DOCKER_NAME"]
  when "baseimage-alpine"
  when "baseimage-centos"
  when "dockerspec"
    commands += [
      ["/usr/bin/docker",         ENV["DOCKER_VERSION"]],
      ["/usr/bin/docker-compose", ENV["DOCKER_COMPOSE_VERSION"]],
    ]
    packages += [
      "git",
      "make",
      "openssh-client",
      ["ruby",                    ENV["RUBY_VERSION"]],
      ["ruby-io-console",         ENV["RUBY_VERSION"]],
      ["ruby-irb",                ENV["RUBY_VERSION"]],
      ["ruby-rdoc",               ENV["RUBY_VERSION"]],
      ["docker-api",              ENV["GEM_DOCKER_API_VERSION"],  "gem"],
      ["rspec",                   ENV["GEM_RSPEC_VERSION"],       "gem"],
      ["serverspec",              ENV["GEM_SERVERSPEC_VERSION"],  "gem"],
    ]
  else
    raise "Unknown image #{ENV["DOCKER_NAME"]}"
  end

  ##############################################################################

  describe docker_image(ENV["DOCKER_IMAGE"]) do
    # Execute Serverspec command locally
    before(:each) { set :backend, :exec }
    it { is_expected.to exist }
  end

  ##############################################################################

  describe "Operating system" do
    it "should be #{ENV["BASE_IMAGE_OS_NAME"]} #{ENV["BASE_IMAGE_OS_VERSION"]}"  do
      expect(os[:family]).to eq(ENV["BASE_IMAGE_OS_FAMILY"])
      expect(os[:release]).to match(/^#{Regexp.escape(ENV["BASE_IMAGE_OS_VERSION"])}\./)
    end
  end

  ##############################################################################

  describe "Packages" do
    packages.each do |package, version, installer|
      describe package(package) do
        it { is_expected.to be_installed }                        if installer.nil? && version.nil?
        it { is_expected.to be_installed.with_version(version) }  if installer.nil? && ! version.nil?
        it { is_expected.to be_installed.by(installer) }          if ! installer.nil? && version.nil?
        it { is_expected.to be_installed.by(installer).with_version(version) } if ! installer.nil? && ! version.nil?
      end
    end
  end

  ##############################################################################

  describe "Commands" do
    commands.each do |command, version, args|
      describe "Command \"#{command}\"" do
        subject { file(command) }
        let(:version_regex) { "(^|[^0-9]) #{version}([^0-9]|$)" }
        let(:version_cmd) { "#{command} #{args.nil? ? "--version" : "#{args}"}" }
        it "should be installed#{version.nil? ? "" : " with version \"#{version}\""}" do
          expect(subject).to exist
          expect(subject).to be_executable
          expect(command(version_cmd).stdout).to match(version_regex) unless version.nil?
        end
      end
    end
  end

  ##############################################################################

  describe "Files" do
    files.each do |file, mode, user, group, expectations|
      expectations ||= []
      context file(file) do
        it { is_expected.to exist }
        it { is_expected.to be_file }       if expectations.include?(:be_file)
        it { is_expected.to be_directory }  if expectations.include?(:be_directory)
        it { is_expected.to be_mode(mode) } unless mode.nil?
        it { is_expected.to be_owned_by(user) } unless user.nil?
        it { is_expected.to be_grouped_into(group) } unless group.nil?
        its(:sha256sum) do
          is_expected.to eq(
              Digest::SHA256.file("config/#{subject.name}").to_s
          )
        end if expectations.include?(:eq_sha256sum)
      end
    end
  end

  ##############################################################################

end

################################################################################
