module ZendeskMailMigrator
    
  class Converter
    
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
        doc = create_doc_no_template(fields)
      else
        doc = create_doc_from_template(fields)
      end
      {:requester => fields[:requester], :doc => doc}
    end
      
    def parsemail(mail)
      subject = mail.subject
      requester = mail.from[0]
      created_date = mail.date.to_s
      if mail.multipart?
        description = parsemultipart(mail)
      else            
        description = mail.body.decoded
      end
      fields = {
        :subject         => subject,
        :requester       => requester,
        :created_date    => created_date,
        :description     => description,
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