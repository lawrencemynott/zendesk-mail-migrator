module ZendeskMailMigrator
    
  class XMLConversion < Converter
    require 'libxml'
    
    def create_doc_no_template(fields)
      doc = LibXML::XML::Document.new
      root = LibXML::XML::Node.new("ticket")
      doc.root = root
      add_nodes(root, fields)
      doc
    end
    
    def create_doc_from_template(fields)
      doc = LibXML::XML::Document.file(settings[:template])
      add_nodes(doc.root, fields)
      doc
    end
    
    def add_nodes(root, fields)
      subject = LibXML::XML::Node.new("subject", fields[:subject])
      description = LibXML::XML::Node.new("description", fields[:description])
      created_date = LibXML::XML::Node.new("created-at", fields[:created_date])
      LibXML::XML::Attr.new(created_date, "type", "datetime")
      root << subject
      root << description
      root << created_date
    end
      
  end
  
end