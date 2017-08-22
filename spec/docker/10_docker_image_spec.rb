require "docker_helper"

### DOCKER_IMAGE ###############################################################

describe "Docker image", :test => :docker_image do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### DOCKER_IMAGE #############################################################

  describe docker_image(ENV["DOCKER_IMAGE"]) do
    # Execute Serverspec commands locally
    before(:each) { set :backend, :exec }
    it { is_expected.to exist }
  end

  ### OS #######################################################################

  describe "Operating system" do
    context "family" do
      subject { os[:family] }
      it { is_expected.to eq(ENV["BASE_IMAGE_OS_FAMILY"]) }
    end
    context "release" do
      subject { os[:release] }
      it { is_expected.to match(/^#{Regexp.escape(ENV["BASE_IMAGE_OS_VERSION"])}\./) }
    end
  end

  ### PACKAGES #################################################################

  describe "Packages" do

    # [package, version, installer]
    packages = []

    case ENV["BASE_IMAGE_NAME"]
    when "alpine"
      packages += [
        "bash",
        "ca-certificates",
        "curl",
        ["jq",                    ENV["JQ_VERSION"]],
        "libressl",
        "nmap-ncat",
        ["runit",                 ENV["RUNIT_VERSION"]],
        ["su-exec",               ENV["SU_EXEC_VERSION"]],
        ["tini",                  ENV["TINY_VERSION"]],
      ]
    when "centos"
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
    end

    case ENV["DOCKER_NAME"]
    when "dockerspec"
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
    end

    packages.each do |package, version, installer|
      describe package(package) do
        it { is_expected.to be_installed }                        if installer.nil? && version.nil?
        it { is_expected.to be_installed.with_version(version) }  if installer.nil? && ! version.nil?
        it { is_expected.to be_installed.by(installer) }          if ! installer.nil? && version.nil?
        it { is_expected.to be_installed.by(installer).with_version(version) } if ! installer.nil? && ! version.nil?
      end
    end
  end

  ### COMMANDS #################################################################

  describe "Commands" do

    # [command, version, args]
    commands = []

    case ENV["BASE_IMAGE_NAME"]
    when "centos"
      commands += [
        ["/usr/bin/jq",             ENV["JQ_VERSION"]],
        "/sbin/runit",
        "/sbin/runsvdir",
        "/sbin/su-exec",
        ["/sbin/tini",              ENV["TINI_VERSION"]],
      ]
    end

    case ENV["DOCKER_NAME"]
    when "dockerspec"
      commands += [
        ["/usr/bin/docker",         ENV["DOCKER_VERSION"]],
        ["/usr/bin/docker-compose", ENV["DOCKER_COMPOSE_VERSION"]],
      ]
    end

    commands.each do |command, version, args|
      describe "Command \"#{command}\"" do
        subject { file(command) }
        let(:version_regex) { "(^|\\W)#{version}(\\W|$)" }
        let(:version_cmd) { "#{command} #{args.nil? ? "--version" : "#{args}"}" }
        it "should be installed#{version.nil? ? "" : " with version \"#{version}\""}" do
          expect(subject).to exist
          expect(subject).to be_executable
          expect(command(version_cmd).stdout).to match(version_regex) unless version.nil?
        end
      end
    end
  end

  ### FILES ####################################################################

  describe "Files" do

    # [file, mode, user, group, [expectations]]
    files = [
      ["/docker-entrypoint.sh",                           755, "root", "root", [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/01-lib-messages.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/02-lib-wait-for.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/10-default-command.sh",      644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/20-docker-introspection.sh", 644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/30-environment-certs.sh",    644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/40-server-certs.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/90-exec-command.sh",         644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/etc/bashrc",                                     644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/etc/inputrc",                                    644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/etc/profile",                                    644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/etc/ssl/openssl.cnf",                            644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/root/.bash_logout",                              644, "root", "root", [:be_file, :eq_sha256sum]],
      ["/root/.bash_profile",                             644, "root", "root", [:be_file, :eq_sha256sum]],
    ]

    case ENV["BASE_IMAGE_NAME"]
    when "centos"
      files += [
        # Serverspec does not differentiate between RedHat and CentOS family,
        # we check CentOS specific file
        ["/etc/centos-release",                           644, "root", "root", [:be_file]],
      ]
    end

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
