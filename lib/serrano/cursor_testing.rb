require 'faraday'
require 'multi_json'

query = 'widget'
cursor = '*'
limit = 100
cursor_max = 500
rows = limit

filter = nil
offset = nil
sample = nil
sort = nil
order = nil
facet = nil

args = { query: query, filter: filter, offset: offset,
         rows: limit, sample: sample, sort: sort,
         order: order, facet: facet, cursor: cursor }
opts = args.delete_if { |_k, v| v.nil? }

conn = Faraday.new(url: 'http://api.crossref.org/', request: nil)

def _req(conn, path, opts)
  res = conn.get path, opts
  MultiJson.load(res.body)
end

def _redo_req(conn, path, js, opts, cu, max_avail, cursor_max)
  if !cu.nil? && (cursor_max > js['message']['items'].length)
    res = [js]
    total = js['message']['items'].length
    while !cu.nil? && (cursor_max > total) && (total < max_avail)
      opts[:cursor] = cu
      out = _req(conn, path, opts)
      cu = out['message']['next-cursor']
      res << out
      total = res.collect { |x| x['message']['items'].length }.inject(:+)
    end
    res
  else
    js
  end
end

path = 'works'

js = _req(conn, path, opts)
cu = js['message']['next-cursor']
max_avail = js['message']['total-results']
res = _redo_req(conn, path, js, opts, cu, max_avail, cursor_max)
