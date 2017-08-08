require "docker_helper"

if ENV["BASEIMAGE_NAME"] == "alpine" then

  describe "Operating system" do
    it "is #{ENV["BASEIMAGE_OS_NAME"]} #{ENV["BASEIMAGE_OS_VERSION"]}"  do
      expect(os[:family]).to eq(ENV["BASEIMAGE_OS_FAMILY"])
      expect(os[:release]).to match(/^#{Regexp.escape(ENV["BASEIMAGE_OS_VERSION"])}\./)
    end
  end

  describe "Package" do
    packages = [
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
      packages += [
        "git",
        "make",
        "openssh-client",
        ["ruby", ENV["RUBY_VERSION"]],
        ["ruby-io-console", ENV["RUBY_VERSION"]],
        ["ruby-irb", ENV["RUBY_VERSION"]],
        ["ruby-rdoc", ENV["RUBY_VERSION"]],
      ]
    end

    packages.each do |package, version|
      context package do
        it "is installed" do
          expect(package(subject)).to be_installed
          expect(package(subject)).to be_installed.with_version(version) unless version.nil?
        end
      end
    end
  end

end

if ENV["DOCKER_NAME"] == "dockerspec" then
  describe "Command" do
    [
      ["/usr/bin/docker", "Docker version #{ENV["DOCKER_VERSION"]},"],
      ["/usr/bin/docker-compose", "docker-compose version #{ENV["DOCKER_COMPOSE_VERSION"]},"],
    ].each do |command, version|
      context command do
        it "is installed" do
          expect(file(subject)).to exist
          expect(file(subject)).to be_file
          expect(file(subject)).to be_executable
          expect(command("#{subject} --version").stdout).to match(version) unless version.nil?
        end
      end
    end
  end

  describe "Ruby gem" do
    [
      ["docker-api",  ENV["GEM_DOCKER_API_VERSION"]],
      ["rspec",       ENV["GEM_RSPEC_VERSION"]],
      ["serverspec",  ENV["GEM_SERVERSPEC_VERSION"]],
    ].each do |package, version|
      context package do
        it "is installed" do
          expect(package(subject)).to be_installed.by("gem")
          expect(package(subject)).to be_installed.by("gem").with_version(version) unless version.nil?
        end
      end
    end
  end

  describe "Process" do
    [
      ["/sbin/tini", 1],
    ].each do |process, pid|
      context process do
        subject do
          process(process)
        end
        it "is running" do
          expect(subject).to be_running
          expect(subject.pid).to eq(pid) unless pid.nil?
        end
      end
    end
  end

end
