# Array methods
class Array
  def links(just_urls = false)
  	tmp = self[0]['message']['link']
  	return parse_link(tmp, just_urls)
  end
end

class Array
  def links_xml(just_urls = false)
  	return parse_link(pull_link(self, 'application\/xml|text\/xml'), just_urls)
  end
end

class Array
  def links_pdf(just_urls = false)
    return parse_link(pull_link(self, 'application\/pdf'), just_urls)
  end
end

class Array
  def links_plain(just_urls = false)
    return parse_link(pull_link(self, 'application\/plain|text\/plain'), just_urls)
  end
end

def pull_link(x, y)
  return x[0]['message']['link'].select { |z| z['content-type'].match(/#{y}/) }
end

def parse_link(x, just_urls)
	if x.nil?
		return x
	else
  	if just_urls
  		return x.collect { |z| z['URL'] }.flatten
  	else
  		return x
  	end
  end
end
