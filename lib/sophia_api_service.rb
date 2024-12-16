# frozen_string_literal: true

require_relative "sophia_api_service/version"

# Implement all Sophia API calls
class SophiaApiService
  def initialize
    # Initialize base configuration to retrieve information from Sophia's API
    @sophia_routes = SophiaRoutes.new
    @sophia_user = ENV.fetch("SOPHIA_USER", nil)
    @sophia_password = ENV.fetch("SOPHIA_PASSWORD", nil)
    @should_use_ssl = ENV.fetch("IS_SOPHIA_PRODUCTION", true)
    @sophia_token = authenticate
    return if @sophia_user.blank? || @sophia_password.blank?

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

  def get_collaborator_by_email(email)
    url = URI("#{@sophia_routes.collaborators_route}?Email=#{email}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = @should_use_ssl
    request = Net::HTTP::Get.new(url)
    request["Token"] = @sophia_token
    SophiaResponse.new(https.request(request))
  end

  def get_teachers_by_units(teachers_units, branch_teachers)
    # This method returns the following structure {'teacher01@gmail.com': ['Mód BOOK 1', 'Mód BOOK 2']}
    classes = get_classes_by_units(teachers_units)

    if branch_teachers
      classes = classes.select do |class_unit|
        class_unit['nomeResumido'].to_s.include?('@')
      end
    end

    teachers = {}
    classes.each do |teacher_class|
      unless teacher_class['colaborador'].blank? || teacher_class['colaborador']['email'].blank?
        teacher_email = teacher_class['colaborador']['email'].downcase.strip
        teacher_class_description = teacher_class['curso']['descricao']
        if teachers.include?(teacher_email)
          teachers[teacher_email]['modulos'] |= [teacher_class_description]
        else
          # Try to create similar Sophia Student structure to teachers
          teachers[teacher_email] = {
            'email' => teacher_email,
            'nome' => teacher_class['colaborador']['nome'],
            'codigo' => teacher_class['colaborador']['codigo'],
            'modulos' => [teacher_class_description]
          }
        end
      end
    end
    teachers.values
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

  def get_courses_without_books(classes_without_books_ids)
    url = URI(@sophia_routes.courses_route)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = @should_use_ssl
    request = Net::HTTP::Get.new(url)
    request["Token"] = @sophia_token
    response = https.request(request)
    JSON.parse(response.read_body)
    result = JSON.parse(response.read_body)
    final_result = []
    result.each do |course|
      if classes_without_books_ids.include?(course['codigo'])
        final_result << "Mód. #{course['nomeResumido']}"
      end
    end
    final_result
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
    SophiaResponse.new(http_response)
  end
end

