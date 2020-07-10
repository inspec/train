require "helper"
require "tempfile"
require "train/transports/helpers/azure/file_credentials"

describe "parse_credentials_file" do
  let(:cred_file_single_entry) do
    file = Tempfile.new("cred_file")
    info = <<-INFO
      [my_subscription_id]
      client_id = "my_client_id"
      client_secret = "my_client_secret"
      tenant_id = "my_tenant_id"
    INFO
    file.write(info)
    file.close
    file
  end

  let(:cred_file_multiple_entries) do
    file = Tempfile.new("cred_file")
    info = <<-INFO
      [my_subscription_id]
      client_id = "my_client_id"
      client_secret = "my_client_secret"
      tenant_id = "my_tenant_id"

      [my_subscription_id2]
      client_id = "my_client_id2"
      client_secret = "my_client_secret2"
      tenant_id = "my_tenant_id2"
    INFO
    file.write(info)
    file.close
    file
  end

  let(:options) { { credentials_file: cred_file_multiple_entries.path } }

  it "handles a nil file" do
    options[:credentials_file] = nil

    result = Train::Transports::Helpers::Azure::FileCredentials.parse(**options)

    assert_empty(result)
  end

  it "returns empty hash when no credentials file detected" do
    result = Train::Transports::Helpers::Azure::FileCredentials.parse(**{})

    assert_empty(result)
  end

  it "loads only entry from file when no subscription id given" do
    options[:credentials_file] = cred_file_single_entry.path

    result = Train::Transports::Helpers::Azure::FileCredentials.parse(**options)

    assert_equal("my_tenant_id",       result[:tenant_id])
    assert_equal("my_client_id",       result[:client_id])
    assert_equal("my_client_secret",   result[:client_secret])
    assert_equal("my_subscription_id", result[:subscription_id])
  end

  it "raises an error when no subscription id given and multiple entries" do
    error = assert_raises RuntimeError do
      Train::Transports::Helpers::Azure::FileCredentials.parse(**options)
    end

    assert_equal("Credentials file must have one entry. Check your credentials file. If you have more than one entry set AZURE_SUBSCRIPTION_ID environment variable.", error.message)
  end

  it "loads entry when subscription id is given" do
    options[:subscription_id] = "my_subscription_id"

    result = Train::Transports::Helpers::Azure::FileCredentials.parse(**options)

    assert_equal("my_tenant_id",       result[:tenant_id])
    assert_equal("my_client_id",       result[:client_id])
    assert_equal("my_client_secret",   result[:client_secret])
    assert_equal("my_subscription_id", result[:subscription_id])
  end

  it "raises an error when subscription id not found" do
    options[:subscription_id] = "missing_subscription_id"

    error = assert_raises RuntimeError do
      Train::Transports::Helpers::Azure::FileCredentials.parse(**options)
    end

    assert_equal("No credentials found for subscription number missing_subscription_id", error.message)
  end

  it "loads entry based on index" do
    ENV["AZURE_SUBSCRIPTION_NUMBER"] = "2"

    result = Train::Transports::Helpers::Azure::FileCredentials.parse(**options)

    ENV.delete("AZURE_SUBSCRIPTION_NUMBER")

    assert_equal("my_tenant_id2",       result[:tenant_id])
    assert_equal("my_client_id2",       result[:client_id])
    assert_equal("my_client_secret2",   result[:client_secret])
    assert_equal("my_subscription_id2", result[:subscription_id])
  end

  it "raises an error when index is out of bounds" do
    ENV["AZURE_SUBSCRIPTION_NUMBER"] = "3"

    error = assert_raises RuntimeError do
      Train::Transports::Helpers::Azure::FileCredentials.parse(**options)
    end
    ENV.delete("AZURE_SUBSCRIPTION_NUMBER")

    assert_equal("Your credentials file only contains 2 subscriptions. You specified number 3.", error.message)
  end

  it "raises an error when index 0 is given" do
    ENV["AZURE_SUBSCRIPTION_NUMBER"] = "0"

    error = assert_raises RuntimeError do
      Train::Transports::Helpers::Azure::FileCredentials.parse(**options)
    end
    ENV.delete("AZURE_SUBSCRIPTION_NUMBER")

    assert_equal("Index must be greater than 0.", error.message)
  end
end
