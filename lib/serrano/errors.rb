require 'net/http'

def rescue_faraday_error(url, error, options={})
  details = nil
  headers = {}

  if error.is_a?(Faraday::Error::TimeoutError)
    status = 408
  elsif error.respond_to?('status')
    status = error[:status]
  elsif error.respond_to?('response') && error.response.present?
    status = error.response[:status]
    details = error.response[:body]
    headers = error.response[:headers]
  else
    status = 400
  end

  # Some sources use a different status for rate-limiting errors
  status = 429 if status == 403 && details.include?("Excessive use detected")

  if error.respond_to?('exception')
    exception = error.exception
  else
    exception = ""
  end

  class_name = class_name_by_status(status) || error.class

  message = parse_error_response(error.message)
  message = "#{message} for #{url}"
  message = "#{message} with rev #{options[:data][:rev]}" if class_name == Net::HTTPConflict

  { error: message, status: status }
end

def parse_error_response(string)
  if is_json?(string)
    string = MultiJson.load(string)
  end
  string = string['error'] if string.is_a?(Hash) && string['error']
  string
end

def is_json?(string)
  MultiJson.load(string)
rescue MultiJson::ParseError => e
  e.data
  e.cause
end

def class_name_by_status(status)
  { 400 => Net::HTTPBadRequest,
    401 => Net::HTTPUnauthorized,
    403 => Net::HTTPForbidden,
    404 => Net::HTTPNotFound,
    406 => Net::HTTPNotAcceptable,
    408 => Net::HTTPRequestTimeOut,
    409 => Net::HTTPConflict,
    417 => Net::HTTPExpectationFailed,
    429 => Net::HTTPTooManyRequests,
    500 => Net::HTTPInternalServerError,
    502 => Net::HTTPBadGateway,
    503 => Net::HTTPServiceUnavailable,
    504 => Net::HTTPGatewayTimeOut }.fetch(status, nil)
end

