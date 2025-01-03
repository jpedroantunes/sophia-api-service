# frozen_string_literal: true

require_relative "sophia_service/version"

# Implement all Sophia API calls
module SophiaService
  autoload :ApiClient, "sophia_service/api_client"
  autoload :SophiaRoutes, "sophia_service/sophia_routes"
  autoload :SophiaResponse, "sophia_service/sophia_response"

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # Implement Sophia Service configuration
  class Configuration
    attr_reader :base_url, :sophia_user, :sophia_password, :is_sophia_production

    def initialize
      @base_url = ""
      @sophia_user = ""
      @sophia_password = ""
      @is_sophia_production = true
    end

    def set_configuration(base_url:, sophia_user:, sophia_password:, is_sophia_production:)
      @base_url = base_url
      @sophia_user = sophia_user
      @sophia_password = sophia_password
      @is_sophia_production = is_sophia_production
    end
  end
end
