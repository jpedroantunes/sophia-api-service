# frozen_string_literal: true

# Class encapsulating all available Sophia Routes
class SophiaRoutes
  def initialize
    @sophia_base_url = ENV.fetch("SOPHIA_URL", nil)
    return if @sophia_base_url.blank?

    raise "The Sophia Base URL 'SOPHIA_URL' may be defined as an environment variable"
  end

  def students_route
    "#{@sophia_base_url}/Alunos"
  end

  def authentication_route
    "#{@sophia_base_url}/Autenticacao"
  end

  def classes_route
    "#{@sophia_base_url}/Turmas"
  end

  def courses_route
    "#{@sophia_base_url}/Cursos"
  end

  def collaborators_route
    "#{@sophia_base_url}/Colaboradores"
  end

  def sales_route
    "#{@sophia_base_url}/Vendas"
  end
end