module Payonline
  class FiscalResponse
    SUCCESS_CODE = -1

    def initialize(response)
      @response = parse_response(response)
    end

    def success?
      @response[:status][:code] == SUCCESS_CODE
    end

    def failure?
      !success?
    end

    private

    def parse_response(response)
      JSON.parse(response).with_indifferent_access
    end
  end
end
