require "docker_helper"

################################################################################

describe "Server certificate", :test => :server_certs do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ##############################################################################

  user = "root"
  group = "root"

  crt = ENV["SERVER_CRT_FILE"]      || "/etc/ssl/certs/server_crt.pem"
  key = ENV["SERVER_KEY_FILE"]      || "/etc/ssl/private/server_key.pem"
  pwd = ENV["SERVER_KEY_PWD_FILE"]  || "/etc/ssl/private/server_key.pwd"
  p12 = ENV["SERVER_P12_FILE"]      || "/etc/ssl/private/server.p12"

  subj = ENV["SERVER_CRT_SUBJECT"]  || "CN=#{ENV["CONTAINER_NAME"]}"

  ##############################################################################

  describe x509_certificate(crt) do
    let(:file) { Serverspec::Type::File.new(subject.name) }
    it { expect(file).to be_a_file }
    it { expect(file).to be_mode(644) }
    it { expect(file).to be_owned_by(user) }
    it { expect(file).to be_grouped_into(group) }
    it { is_expected.to be_a_certificate }
    it { is_expected.to be_valid }
    its(:subject) { is_expected.to eq "/#{subj}" }
    its(:issuer)  { is_expected.to eq "/CN=Docker Simple CA" }
    its(:validity_in_days) { is_expected.to be > 3650 }
    context "subject_alt_names" do
      it { expect(subject.subject_alt_names).to include("DNS:#{ENV["SERVER_CRT_HOST"]}") } unless ENV["SERVER_CRT_HOST"].nil?
      it { expect(subject.subject_alt_names).to include("DNS:#{ENV["CONTAINER_NAME"]}") }
      it { expect(subject.subject_alt_names).to include("DNS:localhost") }
      it { expect(subject.subject_alt_names).to include("IP Address:#{ENV["SERVER_CRT_IP"]}") } unless ENV["SERVER_CRT_IP"].nil?
      it { expect(subject.subject_alt_names).to include("IP Address:127.0.0.1") }
      it { expect(subject.subject_alt_names).to include("Registered ID:#{ENV["SERVER_CRT_OID"]}") } unless ENV["SERVER_CRT_OID"].nil?
    end
  end

  ##############################################################################

  describe "X509 private key passphrase \"#{pwd}\"" do
    let (:file) { Serverspec::Type::File.new(pwd) }
    it { expect(file).to be_a_file }
    # TODO: server_key.pwd is mounted through Docker Compose with strange owner
    # it { expect(file).to be_mode(640) }
    # it { expect(file).to be_owned_by(user) }
    # it { expect(file).to be_grouped_into(group) }
  end

  ##############################################################################

  describe x509_private_key(key, {:passin => "file:#{pwd}"}) do
    let(:file) { Serverspec::Type::File.new(key) }
    it { expect(file).to be_a_file }
    it { expect(file).to be_mode(640) }
    it { expect(file).to be_owned_by(user) }
    it { expect(file).to be_grouped_into(group) }
    it { is_expected.to be_encrypted }
    it { is_expected.to be_valid }
    it { is_expected.to have_matching_certificate(crt) }
  end

  ##############################################################################

  # TODO: Serverspec does not support PKCS12 keystores
  #describe pkcs12_keystore(p12, {:passin => "file:#{pwd}"}) do
  describe "PKCS12 keystore \"#{p12}\"" do
    let(:file) { Serverspec::Type::File.new(p12) }
    it { expect(file).to be_a_file }
    it { expect(file).to be_mode(640) }
    it { expect(file).to be_owned_by(user) }
    it { expect(file).to be_grouped_into(group) }
    # TODO: Serverspec does not support PKCS12 keystores
    # it { is_expected.to be_encrypted }
    # it { is_expected.to be_valid }
  end

  ##############################################################################

end

################################################################################
