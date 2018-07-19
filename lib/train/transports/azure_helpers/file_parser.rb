# encoding: utf-8

module Train
  module Transports
    module AzureHelpers
      class FileParser
        def initialize(credentials)
          @credentials = credentials

          validate!
        end

        def validate!
          return if @credentials.sections.count < 2

          raise 'Multiple credentials detected, please set the AZURE_SUBSCRIPTION_ID environment variable.'
        end

        def subscription_id
          @subscription_id ||= @credentials.sections[0]
        end
      end
    end
  end
end
