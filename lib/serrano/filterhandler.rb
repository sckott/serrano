# helper functions
module Helpers

  $others = ['license_url','license_version','license_delay','full_text_version','full_text_type',
             'award_number','award_funder']

  def filter_handler(x = nil)
    if x.nil?
      nil
    else
      x = stringify(x)
      nn = x.keys.collect{ |z| z.to_s }
      if nn.collect{ |w| $others.include? w }.any?
        nn = nn.collect{ |b|
          if $others.include? b
            case b
            when 'license_url'
              'license.url'
            when 'license_version'
              'license.version'
            when 'license_delay'
              'license.delay'
            when 'full_text_version'
              'full-text.version'
            when 'full_text_type'
              'full-text.type'
            when 'award_number'
              'award.number'
            when 'award_funder'
              'award.funder'
            end
          else
            b
          end
        }
      end

      newnn = nn.collect{ |m| m.gsub("_", "-") }
      x = rename_keys(x, newnn)
      x = x.collect{ |k,v| [k, v].join(":") }.join(',')
      return x
    end
  end

  def stringify(x)
    (x.keys.map{ |k,v| k.to_s }.zip x.values).to_h
  end

  def rename_keys(x, y)
    (y.zip x.values).to_h
  end

end

module Serrano
  class Request #:nodoc:
    include Helpers
  end

  class RequestCursor #:nodoc:
    include Helpers
  end
end

