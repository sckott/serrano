# helper functions
module Crossref
	class Request #:nodoc:

		private

		def filter_handler(x = nil)
			if x.nil?
				nil
			else
				x = x.stringify
				nn = x.keys.collect{ |x| x.to_s }
				if nn.collect{ |x| others.include? x }.any?
					nn = nn.collect{ |x|
						if others.include? x
							case x
							when license_url
								return 'license.url'
							when license_version
								return 'license.version'
			        when license_delay
			        	return 'license.delay'
			        when full_text_version
			        	return 'full-text.version'
			        when full_text_type
			        	return 'full-text.type'
			        when award_number
			        	return 'award.number'
			        when award_funder
			        	return 'award.funder'
							end
						else
							x
						end
					}
				end

				newnn = nn.collect{ |x| x.gsub("_", "-") }
				x = x.rename_keys newnn
				x = x.collect{ |k,v| [k, v].join(":") }.join(',')
				return x
			end
		end

		class Hash
			def stringify
				(self.keys.map{ |k,v| k.to_s }.zip self.values).to_h
			end
		end

		class Hash
			def rename_keys(x)
				(x.zip self.values).to_h
			end
		end

		others = ['license_url','license_version','license_delay','full_text_version','full_text_type',
		           'award_number','award_funder']

		filterchoices = [
		  'has_funder','funder','prefix','member','from_index_date','until_index_date',
		  'from_deposit_date','until_deposit_date','from_update_date','until_update_date',
		  'from_first_deposit_date','until_first_deposit_date','from_pub_date','until_pub_date',
		  'has_license','license_url','license_version','license_delay','has_full_text',
		  'full_text_version','full_text_type','public_references','has_references','has_archive',
		  'archive','has_orcid','orcid','issn','type','directory','doi','updates','is_update',
		  'has_update_policy','container_title','publisher_name','category_name','type_name'
		]

	end

end
