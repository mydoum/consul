class Request
  include DocumentVariants

  def initialize(document_type, document_number)
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(client_call(document_type, variant))
      return response if response.valid?
    end
    return nil
  end

  private

    def client
      @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
    end

    def request(document_type, document_number)
      { request:
        { codigo_institucion: Rails.application.secrets.census_api_institution_code,
          codigo_portal:      Rails.application.secrets.census_api_portal_name,
          codigo_usuario:     Rails.application.secrets.census_api_user_code,
          documento:          document_number,
          tipo_documento:     document_type,
          codigo_idioma:      102,
          nivel: 3 }}
    end

    def client_call(document_type, document_number)
      if end_point_available?
        client.call(:get_habita_datos, message: request(document_type, document_number)).body
      else
        stubbed_response_body
      end
    end

    def end_point_available?
      Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
    end

    def stubbed_response_body
      {get_habita_datos_response: {get_habita_datos_return: {hay_errores: false, datos_habitante: { item: {fecha_nacimiento_string: "31-12-1980", identificador_documento: "12345678Z", descripcion_sexo: "Varón" }}, datos_vivienda: {item: {codigo_postal: "28013", codigo_distrito: "01"}}}}}
    end

end