# frozen_string_literal: true

require_relative "sophia_service/version"

# Implement all Sophia API calls
module SophiaService
  autoload :ApiClient, "sophia_service/api_client"
  autoload :SophiaRoutes, "sophia_service/sophia_routes"
  autoload :SophiaResponse, "sophia_service/sophia_response"

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
