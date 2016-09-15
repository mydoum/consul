class CensusApi

  def call(document_type, document_number)
    request = CensusApi::Request.new(document_type, document_number)
    CensusApi::Response.new(request)
  end

end
