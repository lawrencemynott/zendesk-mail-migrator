require 'libxml'

module ZendeskMailMigrator
    
  class XMLConversion
    
    def initialize(values)
      self.settings = {:template => nil}.merge!(values)
    end
    
    attr_accessor :settings
      
    def convert(mails)
      #convert each mail, adding to the list of tickets
      tickets = []
      mails.each do |mail|
        tickets << convertmail(mail)
      end
      tickets
    end
      
    def convertmail(mail)
      fields = parsemail(mail)
      if settings[:template].nil?
        doc = create_xml_no_doc(fields)
      else
        doc = create_xml_from_doc(fields)
      end
      {:requester => fields['requester'], :doc => doc}
    end
    
    def create_xml_no_doc(fields)
      doc = LibXML::XML::Document.new
      root = LibXML::XML::Node.new("ticket")
      doc.root = root
      subject = LibXML::XML::Node.new("subject", fields['subject'])
      description = LibXML::XML::Node.new("description", fields['description'])
      root << subject
      root << description
      doc
    end
    
    def create_xml_from_doc(fields)
      context = LibXML::XML::Parser::Context.file(settings[:template])
      parser = LibXML::XML::Parser.new(context)
      doc = parser.parse
      context.close
      root = doc.root
      subject = LibXML::XML::Node.new("subject", fields['subject'])
      description = LibXML::XML::Node.new("description", fields['description'])
      root << subject
      root << description
      doc
    end
      
    def parsemail(mail)
      subject = mail.subject
      requester = mail.from[0]
      if mail.multipart?
        description = parsemultipart(mail)
      else            
        description = mail.body.decoded
      end
      fields = {
        'subject'     => subject,
        'requester'   => requester,
        'description' => description,
      }
      fields
    end
    
    def parsemultipart(mail)
      i = mail.parts.index {|part| part.content_type =~ /text\/plain/}
      return mail.parts[i].body.decoded if !i.nil?
      i = mail.parts.index {|part| part.content_type =~ /text\/html/}
      return strip_html_tags(mail.parts[i].body.decoded) if !i.nil?
      return ""
    end
    
    def strip_html_tags(string)
      string
    end
      
  end
  
end