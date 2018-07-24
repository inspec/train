require 'azure_graph_rbac'

class GraphRbac

  AUTH_ENDPOINT = MsRestAzure::AzureEnvironments::AzureCloud.active_directory_endpoint_url
  API_ENDPOINT = MsRestAzure::AzureEnvironments::AzureCloud.active_directory_graph_resource_id

  def self.client(credentials)
    provider = ::MsRestAzure::ApplicationTokenProvider.new(
        credentials[:tenant_id],
        credentials[:client_id],
        credentials[:client_secret],
        settings
    )
    credentials[:credentials] = ::MsRest::TokenCredentials.new(provider)
    credentials[:base_url] = API_ENDPOINT
    ::Azure::GraphRbac::Profiles::Latest::Client.new(credentials)
  end
  private

  def self.settings
    client_settings = MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings
    client_settings.authentication_endpoint = AUTH_ENDPOINT
    client_settings.token_audience = API_ENDPOINT
  end
end