# encoding: utf-8
# frozen_string_literal: true

require 'azure_mgmt_key_vault'

# Wrapper class for ::Azure::KeyVault::Profiles::Latest::Mgmt::Client allowing custom configuration,
# for example, defining additional settings for the ::MsRestAzure::ApplicationTokenProvider.
class Vault
  def initialize(vault_name)
    if vault_name.nil?
      raise ::Train::UserError, 'Vault Name cannot be nil'
    end
    @auth_endpoint = MsRestAzure::AzureEnvironments::AzureCloud.active_directory_endpoint_url
    @api_endpoint = "https://#{vault_name}#{MsRestAzure::AzureEnvironments::AzureCloud.key_vault_dns_suffix}"
    @resource_endpoint = 'https://vault.azure.net'
  end

  def client(credentials)
    provider = ::MsRestAzure::ApplicationTokenProvider.new(
      credentials[:tenant_id],
      credentials[:client_id],
      credentials[:client_secret],
      settings,
    )
    credentials[:credentials] = ::MsRest::TokenCredentials.new(provider)
    credentials[:base_url] = @api_endpoint
    ::Azure::KeyVault::Profiles::Latest::Mgmt::Client.new(credentials)
  end

  def settings
    client_settings = MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings
    client_settings.authentication_endpoint = @auth_endpoint
    client_settings.token_audience = @resource_endpoint
    client_settings
  end
end
