module ZendeskMailMigrator
  
  class JSONDelivery < Deliverer
    require "json"
    
    def initialize(values)
      super(values)
      settings[:extension] = "json"
    end
    
    def is_agent(json)
      hash = JSON.parse(json)
      if hash.empty?
        return -1
      end
      hash[0]["roles"]
    end
    
    def set_requester_email(ticket)
      hash = JSON.parse(ticket[:doc])
      hash["ticket"]["requester_email"] = ticket[:requester]
      ticket[:doc] = JSON.generate(hash)
    end
    
  end
  
end