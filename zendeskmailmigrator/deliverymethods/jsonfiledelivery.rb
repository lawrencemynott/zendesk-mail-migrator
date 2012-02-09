module ZendeskMailMigrator
  class JSONFileDelivery
    require 'json'
    
    def initialize(values)
      self.settings = {:output => "."}.merge!(values)
    end
    
    attr_accessor :settings
      
    def deliver(tickets)
        
      tickets.length.times do |i|
        jsonfile = File.new("#{settings[:output]}/#{i}.json", "w")
        hash = JSON.parse(tickets[i][:doc])
        doc = JSON.pretty_generate(hash)
        jsonfile << doc
        jsonfile.close
      end
        
    end
      
  end
    
  
end