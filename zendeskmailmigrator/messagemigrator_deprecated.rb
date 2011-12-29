module MailMigrator
  
  class MessageMigrator
    
    def migrateAll
      # obtain all emails from configured retriever
      mails = MailMigrator.retriever_method.all
      # parse each email using configured converter, creating a list of tickets
      tickets = MailMigrator.conversion_method.convert(mails)
      # push each ticket into Zendesk using configured delivery method
      MailMigrator.delivery_method.deliver(tickets)
    end
    
  end
  
end