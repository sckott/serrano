require 'nokogiri'

def detect_type(x)
  ctype = x.headers['content-type']
  case ctype
  when 'text/xml'
    'xml'
  when 'text/plain'
    'plain'
  when 'application/pdf'
    'pdf'
  end
end

def make_path(x, type)
  id = x.split('article/')[1].split('?')[0]
  path = id + '.' + type
  return path
end

def write_disk(res, path)
  f = File.new(path, "wb")
  f.write(res.body)
  f.close()
end

def read_disk(path)
  return File.read(path)
end

def parse_xml(x)
  text = read_disk(x)
  xml = Nokogiri.parse(text)
  return xml
end

def parse_plain(x)
  text = read_disk(x)
  return text
end

def parse_pdf(x)
  raise "not ready yet"
end
