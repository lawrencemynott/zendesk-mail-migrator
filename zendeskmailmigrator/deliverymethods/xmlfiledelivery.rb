module ZendeskMailMigrator
  class XMLFileDelivery
    require 'libxml'
    
    def initialize(values)
      self.settings = {:output => "."}.merge!(values)
    end
    
    attr_accessor :settings
      
    def deliver(tickets)
        
      tickets.length.times do |i|
        tickets[i][:doc].save("#{settings[:output]}/#{i}.xml", :indent => true)
      end
        
    end
      
  end
    
  
end