# Array methods
class Array
  def links(just_urls = false)
    return self.collect{ |x| x.links(just_urls) }.flatten
    # if temp.length == 1
    #   return tmp[0]
    # else
    #   return tmp
    # end
  	# tmp = self.collect{ |x| x['message']['link'] }
  	# return parse_link(tmp, just_urls)
  end
end

class Array
  def links_xml(just_urls = false)
    return parse_link(self.collect { |z| z.links_xml }[0], just_urls)
  	# return parse_link(pull_link(self, '^application\/xml$|^text\/xml$'), just_urls)
  end
end

class Array
  def links_pdf(just_urls = false)
    return parse_link(self.collect { |z| z.links_pdf }[0], just_urls)
    # return parse_link(pull_link(self, '^application\/pdf$'), just_urls)
  end
end

class Array
  def links_plain(just_urls = false)
    return parse_link(self.collect { |z| z.links_plain }[0], just_urls)
    # return parse_link(pull_link(self, '^application\/plain$|^text\/plain$'), just_urls)
  end
end

def pull_link(x, y)
  return x.collect { |z| z.links_xml }[0]
  # return x.collect { |z| z['message']['link'] }.compact.collect { |z| z.compact.select { |w| w['content-type'].match(/#{y}/) } }
end

def parse_link(x, just_urls)
	if x.nil?
		return x
	else
  	if just_urls
  		return x.compact.collect { |z| z.collect{ |y| y['URL'] }}.flatten
  	else
  		return x
  	end
  end
end
