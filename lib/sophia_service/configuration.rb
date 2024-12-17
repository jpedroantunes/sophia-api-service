# Define the configuration base class for the API Client
class Configuration
  class ApiClientError < StandardError; end

  attr_accessor :base_url, :sophia_user, :sophia_password, :is_sophia_production

  def initialize
    @base_url = nil
    @sophia_user = nil
    @sophia_password = nil
    @is_sophia_production = true
    return unless @sophia_user.nil? || @sophia_password.nil? || @base_url.nil?

    raise "It is mandatory to define the configuration defining the 'SOPHIA_USER', 'SOPHIA_PASSWORD' and 'BASE_URL'"
  end
end
