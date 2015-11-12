require "faraday"
require "multi_json"

def ccite(doi, style, locale, options)
  args = {doi: doi, style: style, locale: locale}
  conn = Faraday.new(:url => $crossciteurl, :request => options)
  begin
    res = conn.get '', args
    return res.body.strip
  rescue Exception => e
    raise e
  end
end

def get_styles
  conn = Faraday.new(:url => "https://api.github.com")

  res = conn.get '/repos/citation-style-language/styles/commits', {per_page: 1}
  json = MultiJson.load(res.body)
  sha = json[0]['sha']

  sty = conn.get "/repos/citation-style-language/styles/git/trees/%s" % sha
  json = MultiJson.load(sty.body)
  files = json['tree'].collect { |a,b| a["path"] }
  csls = files.select { |x| x[/\.csl/] }
	return csls.collect { |z| z.split("\.csl")[0] }
end
