module Train
  module Transports
    module AzureHelpers
      class FileParser
        def initialize(credentials)
          @credentials = credentials

          validate!
        end

        def validate!
          if @credentials.sections.count > 1
            raise 'Multiple credentials detected, please set the AZURE_SUBSCRIPTION_ID environment variable.'
          end
        end

        def subscription_id
          @subscription_id ||= @credentials.sections[0]
        end
      end
    end
  end
end
