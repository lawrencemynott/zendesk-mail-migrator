module ZendeskMailMigrator
  
  class XMLDelivery < Deliverer
    require "libxml"
    
    def initialize(values)
      super(values)
      settings[:extension] = "xml"
    end
    
    def is_agent(xml)
      doc = LibXML::XML::Document.string(xml)
      context = LibXML::XML::XPath::Context.new(doc)
      nodes = context.find("//nil-classes")
      if nodes.length != 0
        return -1
      end
      nodes = context.find("//users/user/roles")
      if nodes.length != 1
        puts "number of roles element for user != 1"
      end
      node = nodes.first
      node.content.to_i
    end
    
    def set_requester_email(ticket)
      requester_email = LibXML::XML::Node.new("requester-email", ticket[:requester])
      ticket[:doc].root << requester_email
    end
    
  end
  
end