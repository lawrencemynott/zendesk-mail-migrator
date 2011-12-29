module ZendeskMailMigrator
    
  class XMLConversion
    
    require 'libxml'
      
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
      doc = LibXML::XML::Document.new
      root = LibXML::XML::Node.new("ticket")
      doc.root = root
      subject = LibXML::XML::Node.new("subject", fields['subject'])
      description = LibXML::XML::Node.new("description", fields['description'])
      root << subject
      root << description
      {:requester => fields['requester'], :doc => doc}
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