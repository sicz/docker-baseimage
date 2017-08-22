require "docker_helper"

### SERVER_CERTIFICATE #########################################################

describe "Server certificate", :test => :server_certs do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### CONFIG ###################################################################

  user = "root"
  group = "root"

  crt = ENV["SERVER_CRT_FILE"]      || "/etc/ssl/certs/server_crt.pem"
  key = ENV["SERVER_KEY_FILE"]      || "/etc/ssl/private/server_key.pem"
  pwd = ENV["SERVER_KEY_PWD_FILE"]  || "/etc/ssl/private/server_key.pwd"
  p12 = ENV["SERVER_P12_FILE"]      || "/etc/ssl/private/server.p12"

  subj = ENV["SERVER_CRT_SUBJECT"]  || "CN=#{ENV["CONTAINER_NAME"]}"

  ### CERTIFICATE ##############################################################

  describe x509_certificate(crt) do
    context "file" do
      subject { file(crt) }
      it { is_expected.to be_a_file }
      it { is_expected.to be_mode(644) }
      it { is_expected.to be_owned_by(user) }
      it { is_expected.to be_grouped_into(group) }
    end
    context "certificate" do
      it { is_expected.to be_a_certificate }
      it { is_expected.to be_valid }
    end
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

  ### PRIVATE_KEY_PASSPHRASE ###################################################

  describe "X509 private key passphrase \"#{pwd}\"" do
    context "file" do
      subject { file(pwd) }
      it { is_expected.to be_a_file }
      it { is_expected.to be_mode(640) }
      # TODO: server_key.pwd is copied to container with strange owner
      # it { is_expected.to be_owned_by(user) }
      # it { is_expected.to be_grouped_into(group) }
    end
  end

  ### PRIVATE_KEY ##############################################################

  describe x509_private_key(key, {:passin => "file:#{pwd}"}) do
    context "file" do
      subject { file(key) }
      it { is_expected.to be_a_file }
      it { is_expected.to be_mode(640) }
      it { is_expected.to be_owned_by(user) }
      it { is_expected.to be_grouped_into(group) }
    end
    context "key" do
      it { is_expected.to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate(crt) }
    end
  end

  ### PKCS12_KEYSTORE ##########################################################

  # TODO: Serverspec does not support PKCS12 keystores
  #describe pkcs12_keystore(p12, {:passin => "file:#{pwd}"}) do
  describe "PKCS12 keystore \"#{p12}\"" do
    context "file" do
      subject { file(p12) }
      it { is_expected.to be_a_file }
      it { is_expected.to be_mode(640) }
      it { is_expected.to be_owned_by(user) }
      it { is_expected.to be_grouped_into(group) }
    end
    context "keystore" do
      # TODO: Serverspec does not support PKCS12 keystores
      # it { is_expected.to be_valid }
      # it { is_expected.to be_encrypted }
      subject { command("openssl pkcs12 -in #{p12} -passin file:#{pwd} -noout -info") }
      it "shoud be valid" do
        expect(subject.exit_status).to eq(0)
        expect(subject.stderr).to match("MAC verified OK")
      end
      it "should be encrypted" do
        expect(subject.stderr).to match("PKCS7 Encrypted data: pbeWithSHA1And40BitRC2-CBC")
      end
    end
    # context "certificate" do
    #   it { is_expected.to be_a_certificate }
    #   it { is_expected.to be_valid }
    # end
    # its(:subject) { is_expected.to eq "/#{subj}" }
    # its(:issuer)  { is_expected.to eq "/CN=Docker Simple CA" }
    # its(:validity_in_days) { is_expected.to be > 3650 }
    # context "subject_alt_names" do
    #   it { expect(subject.subject_alt_names).to include("DNS:#{ENV["SERVER_CRT_HOST"]}") } unless ENV["SERVER_CRT_HOST"].nil?
    #   it { expect(subject.subject_alt_names).to include("DNS:#{ENV["CONTAINER_NAME"]}") }
    #   it { expect(subject.subject_alt_names).to include("DNS:localhost") }
    #   it { expect(subject.subject_alt_names).to include("IP Address:#{ENV["SERVER_CRT_IP"]}") } unless ENV["SERVER_CRT_IP"].nil?
    #   it { expect(subject.subject_alt_names).to include("IP Address:127.0.0.1") }
    #   it { expect(subject.subject_alt_names).to include("Registered ID:#{ENV["SERVER_CRT_OID"]}") } unless ENV["SERVER_CRT_OID"].nil?
    # end
    context "key" do
      # TODO: Serverspec does not support PKCS12 keystores
      # it { is_expected.to be_encrypted }
      # it { is_expected.to be_valid }
      # it { is_expected.to have_matching_certificate(crt) }
      subject { command("openssl pkcs12 -in #{p12} -passin file:#{pwd} -noout -info") }
      it "should be encrypted" do
        expect(subject.exit_status).to eq(0)
        expect(subject.stderr).to match("Shrouded Keybag: pbeWithSHA1And3-KeyTripleDES-CBC")
      end
    end
  end

  ##############################################################################

end

################################################################################
