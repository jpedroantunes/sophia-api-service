# frozen_string_literal: true

# Encapsulates an HTTP base response
class SophiaResponse
  attr_reader :response_body, :response_status_code

  def initialize(http_response)
    @response_status_code = http_response.code.to_i
    @response_body = JSON.parse(http_response.read_body)
  end
end
