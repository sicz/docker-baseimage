require "docker_helper"

describe "Server PEM certificate file" do
  crt = "/etc/ssl/certs/server_crt.pem"
  key = "/etc/ssl/private/server_key.pem"
  pwd = "/etc/ssl/private/server_key.pwd"
  context crt do
    it "has set permissions" do
      expect(file(subject)).to be_a_file
      expect(file(subject)).to be_owned_by("root")
      expect(file(subject)).to be_grouped_into("root")
      expect(file(subject)).to be_readable.by("others")
    end
    it "is valid certificate" do
      expect(x509_certificate(subject)).to be_certificate
      expect(x509_certificate(subject)).to be_valid
      expect(x509_certificate(subject).subject).to eq "/CN=#{ENV["DOCKER_TEST_CONTAINER_NAME"]}"
      expect(x509_certificate(subject).issuer).to eq "/CN=Docker Simple CA"
      expect(x509_certificate(subject).validity_in_days).to be > 3650
      expect(x509_certificate(subject).subject_alt_names).to include("DNS:localhost")
      expect(x509_certificate(subject).subject_alt_names).to include("IP Address:127.0.0.1")
    end
  end
  context key do
    it "has set permissions" do
      expect(file(subject)).to be_a_file
      expect(file(subject)).to be_owned_by("root")
      expect(file(subject)).to be_grouped_into("root")
      expect(file(subject)).not_to be_readable.by("others")
    end
    # it "is valid key" do
    #   # TODO: Serverspec does not support PKCS£8 (see RFC7468) format of encrypted private keys
    #   # expect(x509_private_key(subject)).to be_encrypted
    #   # TODO: Serverspec does not support encrypted private keys
    #   # expect(x509_private_key(subject)).to be_valid
    #   # expect(x509_private_key(subject)).to have_matching_certificate(crt)
    # end
  end
  context pwd do
    # TODO: we currently only check the existence of the file
    # it "has set permissions" do
    it "is a file" do
      expect(file(subject)).to be_a_file
      # TODO: file copied with docker cp have strange owner and group
      # expect(file(subject)).to be_owned_by("root")
      # expect(file(subject)).to be_grouped_into("root")
      # TODO: file copied with docker cp is readable by others
      # expect(file(subject)).not_to be_readable.by("others")
    end
  end
end

describe "Server PKCS12 certificate file" do
  p12 = "/etc/ssl/private/server.p12"
  context p12 do
    it "has set permissions" do
      expect(file(subject)).to be_a_file
      expect(file(subject)).to be_owned_by("root")
      expect(file(subject)).to be_grouped_into("root")
      expect(file(subject)).not_to be_readable.by("others")
    end
  end
end
