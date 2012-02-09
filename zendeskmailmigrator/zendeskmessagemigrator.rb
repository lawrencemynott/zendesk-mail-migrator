require 'singleton'

module ZendeskMailMigrator
  
  class ZendeskMessageMigrator
    include Singleton
    include Utilities
    
    def initialize
      @retriever_method = nil
      @conversion_method = nil
      @delivery_method = nil
      super
    end
    
    attr_reader :conversion_method
    
    def delivery_method(method = nil, settings = {})
      return @delivery_method if @delivery_method && method.nil?
      @delivery_method = lookup_delivery_method(method).new(settings)
      @conversion_method = lookup_conversion_method(method).new(settings)
    end
    
    def lookup_delivery_method(method)
      case method
      when nil
        ZendeskMailMigrator::XMLDelivery
      when :xml
        ZendeskMailMigrator::XMLDelivery
      when :json
        ZendeskMailMigrator::JSONDelivery
      when :xmltest
        ZendeskMailMigrator::XMLFileDelivery #output tickets to be delivered as xml files
      when :jsontest
        ZendeskMailMigrator::JSONFileDelivery #output tickets to be delivered as json files
      else
        method
      end
    end
    
    def lookup_conversion_method(method)
      case method
      when nil
        ZendeskMailMigrator::XMLConversion
      when :xml
        ZendeskMailMigrator::XMLConversion
      when :json
        ZendeskMailMigrator::JSONConversion
      when :xmltest
        ZendeskMailMigrator::XMLConversion
      when :jsontest
        ZendeskMailMigrator::JSONConversion
      else
        method
      end
    end
    
    def retriever_method(method = nil, settings = {})
      return @retriever_method if @retriever_method && method.nil?
      @retriever_method = Mail::Configuration.instance.retriever_method(method,settings)
    end
    
    def migrate(*args)
      # obtain all emails from configured retriever
      mails = retriever_method.find(*args)
      log("number of mails retrieved: #{mails.length}")
      # parse each email using configured converter, creating a list of tickets
      tickets = conversion_method.convert(mails)
      log("number of tickets converted: #{tickets.length}")
      # push each ticket into Zendesk using configured delivery method
      delivery_method.deliver(tickets)
    end
        
  end
  
end