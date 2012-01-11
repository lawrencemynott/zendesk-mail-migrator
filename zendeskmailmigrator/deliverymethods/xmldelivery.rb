require "net/http"
require 'libxml'

module ZendeskMailMigrator
  
  class XMLDelivery
    include Utilities
    
    def initialize(values)
      self.settings = { :subdomain          => "lawrencetestsite.zendesk.com",
                        :path               => "/requests.xml",
                        :username           => "lawrence@zendesk.com",
                        :password           => "croc287",
                        :use_ssl?           => true,
                        :x_on_behalf_of?    => true,
                        :content_type       => "application/xml" }.merge!(values)
    end
    
    attr_accessor :settings
    
    def deliver(tickets)
      # 3 things to think about: limiting to 700 requests per minute, dealing with errors and logging
      # Do the api calls to create the tickets, currently limit api calls to 1 every 0.1 seconds which stays well within the 700 rpm rate limit
      if settings[:use_ssl?]
        uri = URI.parse("https://#{settings[:subdomain]}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        uri = URI.parse("http://#{settings[:subdomain]}")
        http = Net::HTTP.new(uri.host, uri.port)
      end

      # POST request
      req = build_post_request(tickets[0])
      resp = http.request(req)
      
      # Log results
      log_post(req, resp, 0)
      
      # POST remaining tickets limiting to 600 requests per minute
      i=1
      repeat_every(0.1) do
        break if i==tickets.length
        req = build_post_request(tickets[i])
        resp = http.request(req)
        log_post(req, resp, i)
        i+=1
      end
    end
    
    def build_post_request(ticket)
      request = Net::HTTP::Post.new(settings[:path])
      if settings[:x_on_behalf_of?]
        request["X-On-Behalf-Of"] = ticket[:requester]
      else
        requester_email = LibXML::XML::Node.new("requester-email", ticket[:requester])
        ticket[:doc].root << requester_email
      end
      request.basic_auth(settings[:username], settings[:password])
      request["Content-Type"] = settings[:content_type]
      request.body = ticket[:doc].to_s
      request
    end
    
    def log_post(req, resp, id)
      log(">>#{id}:")
      log("Request:")
      req.each {|key, val| log(key + ' = ' + val)}
      log(req.body)
      log("Response:")
      log("Code = " + resp.code)
      log("Message = " + resp.message)
      resp.each {|key, val| log(key + ' = ' + val)}
      log(resp.body)
    end
    
  end
  
end