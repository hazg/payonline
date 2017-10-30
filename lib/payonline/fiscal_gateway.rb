module Payonline
  class FiscalGateway
    BASE_URL = 'https://secure.payonlinesystem.com/Services/Fiscal/Request.ashx'
    SIGNED_PARAMS = %w(request_body merchant_id)

    def initialize(params = {})
      @params = prepare_params(params)
    end

    # Perform the fiscal operation and return the response
    def fiscalization
      response = HTTParty.post(fiscal_url, {
                   body: @params[:request_body],
                   headers: { 'Content-Type' => 'application/json' }
                 })
      return false unless response.success?

      Payonline::FiscalResponse.new(response.body).success?
    end

    # Return the URL without performing a request
    def fiscal_url
      "#{BASE_URL}/?#{fiscal_url_params.to_query}"
    end

    private

    def fiscal_url_params
      security_key = Payonline::Signature.new(@params, SIGNED_PARAMS, true, true).digest
      params = { merchant_id: Payonline.configuration.merchant_id, security_key: security_key }
      params.transform_keys { |key| key.to_s.camelize }
    end

    def prepare_params(params)
      params = params.with_indifferent_access
      params[:request_body][:totalAmount] = format('%.2f', params[:request_body][:totalAmount])
      params.merge!(request_body: params[:request_body].to_json)
    end
  end
end
