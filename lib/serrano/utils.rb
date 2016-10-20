def make_ua
	requa = 'Faraday/v' + Faraday::VERSION
  habua = 'Serrano/v' + Serrano::VERSION
  return requa + ' ' + habua
end

def field_query_handler(x)
	tmp = x.keep_if { |x| x.match(/query_/) }
  return rename_query_filters(tmp)
end

def rename_query_filters(x)
	x = x.tostrings
	x = x.map { |x,y| [x.to_s.sub('container_title', 'container-title'), y] }.to_h
	x = x.map { |x,y| [x.to_s.sub('query_', 'query.'), y] }.to_h
  return x
end

class Hash
	def tostrings
		Hash[self.map{|(k,v)| [k.to_s,v]}]
	end
end

class Hash
	def tosymbols
		Hash[self.map{|(k,v)| [k.to_sym,v]}]
	end
end
