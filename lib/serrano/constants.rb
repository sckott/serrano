require 'net/http'

NETWORKABLE_EXCEPTIONS = [Faraday::Error::ClientError,
                          URI::InvalidURIError,
                          Encoding::UndefinedConversionError,
                          ArgumentError,
                          NoMethodError,
                          TypeError]

