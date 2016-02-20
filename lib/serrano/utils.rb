def make_ua
	requa = 'Faraday/v' + Faraday::VERSION
  habua = 'Serrano/v' + Serrano::VERSION
  return requa + ' ' + habua
end
