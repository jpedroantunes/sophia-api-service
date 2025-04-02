require "uri"
require "net/http"
require "json"

module SophiaService
  # Implement all Sophia API calls
  class ApiClient
    def initialize
      # Initialize base configuration to retrieve information from Sophia's API
      @sophia_routes = SophiaRoutes.new(base_url: SophiaService.configuration.base_url)
      @sophia_user = SophiaService.configuration.sophia_user
      @sophia_password = SophiaService.configuration.sophia_password
      @should_use_ssl = SophiaService.configuration.is_sophia_production
      @sophia_token = authenticate
      return unless @sophia_user.nil? || @sophia_password.nil?

      raise "It is mandatory to define the environment variables: 'SOPHIA_USER' and 'SOPHIA_PASSWORD'"
    end

    def get_students_by_units(units)
      # Convert array of units to a String separated by comma, to send it to Sophia API
      units_query = units.join(",")
      url = URI("#{@sophia_routes.students_route}?Unidades=#{units_query}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def get_student_by_email(email)
      url = URI("#{@sophia_routes.students_route}?Email=#{email}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def get_classes_by_codes(class_codes)
      # Convert array of units to a String separated by comma, to send it to Sophia API
      class_codes_query = class_codes.join(",")
      url = URI("#{@sophia_routes.classes_route}?Codigos=#{class_codes_query}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def get_classes_by_units(class_units)
      # Convert array of units to a String separated by comma, to send it to Sophia API
      class_units_query = class_units.join(",")
      url = URI("#{@sophia_routes.classes_route}?Unidades=#{class_units_query}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def get_classes_by_units_and_situation(class_units, class_situation)
      # Convert array of units and situation to a String separated by comma, to send it to Sophia API
      class_units_query = class_units.join(",")
      class_situation_query = class_situation.join(",")
      url = URI("#{@sophia_routes.classes_route}?Situacoes=#{class_situation_query}&Unidades=#{class_units_query}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def get_collaborator_by_email(email)
      url = URI("#{@sophia_routes.collaborators_route}?Email=#{email}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def get_sales_by_students(students_codes)
      # Convert array of units to a String separated by comma, to send it to Sophia API
      students_codes_query = students_codes.join(",")
      url = URI("#{@sophia_routes.sales_route}?Alunos=#{students_codes_query}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def get_courses
      url = URI(@sophia_routes.courses_route)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Get.new(url)
      request["Token"] = @sophia_token
      SophiaResponse.new(https.request(request))
    end

    def inspect
      "#<SophiaService::ApiClient>"
    end

    private

    def authenticate
      auth_url = URI(@sophia_routes.authentication_route)
      https = Net::HTTP.new(auth_url.host, auth_url.port)
      https.use_ssl = @should_use_ssl
      request = Net::HTTP::Post.new(auth_url)
      request["Content-Type"] = "application/json"
      request.body = JSON.dump({ usuario: @sophia_user, senha: @sophia_password })
      http_response = https.request(request)
      # The Sophia Auth method returns a string instead of a JSON, that why we not use the SophiaResponse object
      http_response.read_body
    end
  end
end
