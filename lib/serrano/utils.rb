def make_ua
  requa = 'Faraday/v' + Faraday::VERSION
  habua = 'Serrano/v' + Serrano::VERSION
  ua = requa + ' ' + habua
  if Serrano.mailto
    ua = ua + " (mailto:%s)" % Serrano.mailto
  end
  # ua += format(' (mailto:%s)', Serrano.mailto) if Serrano.mailto
  ua
end

def field_query_handler(x)
  tmp = x.keep_if { |z| z.match(/query_/) }
  rename_query_filters(tmp)
end

def rename_query_filters(foo)
  foo = foo.tostrings
  foo = foo.map { |x, y| [x.to_s.sub('container_title', 'container-title'), y] }.to_h
  foo = foo.map { |x, y| [x.to_s.sub('query_', 'query.'), y] }.to_h
  foo
end

class Hash
  def tostrings
    Hash[map { |(k, v)| [k.to_s, v] }]
  end
end

class Hash
  def tosymbols
    Hash[map { |(k, v)| [k.to_sym, v] }]
  end
end
