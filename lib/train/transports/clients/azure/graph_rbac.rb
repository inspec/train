require "azure_graph_rbac2"

# Wrapper class for ::Azure::GraphRbac2::Profiles::Latest::Client allowing custom configuration,
# for example, defining additional settings for the ::MsRestAzure2::ApplicationTokenProvider.
class GraphRbac
  AUTH_ENDPOINT = MsRestAzure2::AzureEnvironments::AzureCloud.active_directory_endpoint_url
  API_ENDPOINT = MsRestAzure2::AzureEnvironments::AzureCloud.active_directory_graph_resource_id

  def self.client(credentials)
    credentials[:credentials] = ::MsRest::TokenCredentials.new(provider(credentials))
    credentials[:base_url] = API_ENDPOINT

    ::Azure::GraphRbac2::Profiles::Latest::Client.new(credentials)
  end

  def self.provider(credentials)
    ::MsRestAzure2::ApplicationTokenProvider.new(
      credentials[:tenant_id],
      credentials[:client_id],
      credentials[:client_secret],
      settings
    )
  end

  def self.settings
    client_settings = MsRestAzure2::ActiveDirectoryServiceSettings.get_azure_settings
    client_settings.authentication_endpoint = AUTH_ENDPOINT
    client_settings.token_audience = API_ENDPOINT
    client_settings
  end

  private_class_method :provider, :settings
end
