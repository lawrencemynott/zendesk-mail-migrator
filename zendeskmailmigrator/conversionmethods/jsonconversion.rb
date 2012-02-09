

module ZendeskMailMigrator
  
  class JSONConversion < Converter
    require 'json'
    
    def create_doc_no_template(fields)
      hash = {
                "ticket" => {
                  "subject"       => fields[:subject],
                  "description"   => fields[:description],
                  "created_at"    => fields[:created_date]
                }
              }
      JSON.generate(hash)
    end
    
    def create_doc_from_template(fields)
      json = File.read(settings[:template])
      hash = JSON.parse(json)
      hash["ticket"]["subject"] = fields[:subject]
      hash["ticket"]["description"] = fields[:description]
      hash["ticket"]["created_at"] = fields[:created_date]
      JSON.generate(hash)
    end
    
  end
  
end