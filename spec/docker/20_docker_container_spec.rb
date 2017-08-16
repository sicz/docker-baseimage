require "docker_helper"

################################################################################

describe "Docker container", :test => :docker_container do

  ##############################################################################

  # [process, user, group, pid]
  processes = []
  case ENV["BASE_IMAGE_NAME"]
  when "alpine"
    processes += [
      ["/sbin/tini",              "root", "root", 1],
    ]
  when "centos"
    processes += [
      ["tini",                    "root", "root", 1],
    ]
  else
    raise "Unknown base image #{ENV["BASE_IMAGE_NAME"]}"
  end

  ##############################################################################

  # TODO: Run with exec backend
  # describe docker_container(ENV["CONTAINER_NAME"]) do
  #   it { is_expected.to be_running }
  # end

  ##############################################################################

  describe "Processes" do
    processes.each do |process, user, group, pid|
      context process(process) do
        it { is_expected.to be_running }
        its(:pid) { is_expected.to eq(pid) } unless pid.nil?
        its(:user) { is_expected.to eq(user) } unless user.nil?
        its(:group) { is_expected.to eq(group) } unless group.nil?
      end
    end
  end

  ##############################################################################

end

################################################################################
