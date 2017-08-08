require "docker_helper"

if ENV["BASEIMAGE_NAME"] == "centos" then

  describe "Operating system" do
    it "is #{ENV["BASEIMAGE_OS_NAME"]} #{ENV["BASEIMAGE_OS_VERSION"]}"  do
      expect(os[:family]).to eq(ENV["BASEIMAGE_OS_FAMILY"])
      expect(os[:release]).to match(/^#{Regexp.escape(ENV["BASEIMAGE_OS_VERSION"])}\./)
    end
  end

  describe "Package" do
    [
      "bash",
      "bind-utils",
      "ca-certificates",
      "curl",
      "less",
      "openssl",
      "net-tools",
      "which",
    ].each do |package, version|
      context package do
        it "is installed" do
          expect(package(subject)).to be_installed
          expect(package(subject)).to be_installed.with_version(version) unless version.nil?
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

  describe "Process" do
    [
      ["tini", 1],
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
