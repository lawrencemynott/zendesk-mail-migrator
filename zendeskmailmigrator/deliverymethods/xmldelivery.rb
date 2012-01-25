require "net/http"
require 'libxml'

module ZendeskMailMigrator
  
  class XMLDelivery
    include Utilities
    
    def initialize(values)
      self.settings = { :subdomain                  => "lawrencetestsite.zendesk.com",
                        :username                   => "lawrence@zendesk.com",
                        :password                   => "croc287",
                        :use_ssl?                   => true,
                        :user_lookup?               => true,
                        :path                       => "/tickets.xml",
                        :x_on_behalf_of?            => false }.merge!(values)
    end
    
    attr_accessor :settings
    
    def deliver(tickets)
      # 3 things to think about: limiting to 700 requests per minute, dealing with errors and logging
      # Do the api calls to create the tickets, currently limit api calls to 1 every 0.1 seconds which stays well within the 700 rpm rate limit
      
      # set up http object
      if settings[:use_ssl?]
        uri = URI.parse("https://#{settings[:subdomain]}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        uri = URI.parse("http://#{settings[:subdomain]}")
        http = Net::HTTP.new(uri.host, uri.port)
      end
      
      if settings[:user_lookup?]
        post_tickets_with_user_lookup(tickets, http)
      else
        post_tickets_manual_settings(tickets, http)
      end
      
    end
    
    def post_tickets_with_user_lookup(tickets, http)
      
      # POST first ticket
      req = build_user_lookup_request(tickets[0][:requester])
      resp = http.request(req)
      # Log results
      log_get(req, resp, tickets[0][:requester])
      result = is_agent(resp.body)
      case result
      when -1
        req = build_new_user_post_request(tickets[0])
      when 0
        req = build_end_user_post_request(tickets[0])
      else
        req = build_agent_post_request(tickets[0])
      end
      resp = http.request(req)
      # Log results
      log_post(req, resp, 0)
      
      # POST remaining tickets limiting to 600 requests per minute
      i=1
      repeat_every(0.2) do
        break if i==tickets.length
        req = build_user_lookup_request(tickets[i][:requester])
        resp = http.request(req)
        # Log results
        log_get(req, resp, tickets[i][:requester])
        result = is_agent(resp.body)
        case result
        when -1
          req = build_new_user_post_request(tickets[i])
        when 0
          req = build_end_user_post_request(tickets[i])
        else
          req = build_agent_post_request(tickets[i])
        end
        resp = http.request(req)
        log_post(req, resp, i)
        i+=1
      end
    end
    
    def post_tickets_manual_settings(tickets, http)
      
      # POST first ticket
      req = build_manual_post_request(tickets[0])
      resp = http.request(req)
      # Log results
      log_post(req, resp, 0)
      
      # POST remaining tickets limiting to 600 requests per minute
      i=1
      repeat_every(0.1) do
        break if i==tickets.length
        req = build_manual_post_request(tickets[i])
        resp = http.request(req)
        log_post(req, resp, i)
        i+=1
      end
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
    
    def set_x_on_behalf_of(request, ticket)
      request["X-On-Behalf-Of"] = ticket[:requester]
    end
    
    def build_user_lookup_request(search_string)
      escaped_path = URI.escape("/users.xml?query=#{search_string}")
      request = Net::HTTP::Get.new(escaped_path)
      request.basic_auth(settings[:username], settings[:password])
      request
    end
    
    def create_default_post_request(ticket, path)
      request = Net::HTTP::Post.new(path)
      request.basic_auth(settings[:username], settings[:password])
      request["Content-Type"] = "application/xml"
      yield request, ticket
      request.body = ticket[:doc].to_s
      request
    end
    
    def build_new_user_post_request(ticket)
      create_default_post_request(ticket, "/tickets.xml") do |request, ticket|
        set_requester_email(ticket)
      end
    end
    
    def build_agent_post_request(ticket)
      create_default_post_request(ticket, "/tickets.xml") do |request, ticket|
        if settings[:x_on_behalf_of?]
          set_x_on_behalf_of(request, ticket)
        else
          set_requester_email(ticket)
        end
      end
    end
    
    def build_end_user_post_request(ticket)
      if settings[:x_on_behalf_of?]
        request = create_default_post_request(ticket, "/requests.xml") do |request, ticket|
          set_x_on_behalf_of(request, ticket)
        end
      else
        request = create_default_post_request(ticket, "/tickets.xml") do |request, ticket|
          set_requester_email(ticket)
        end
      end
      request
    end
    
    def build_manual_post_request(ticket)
      create_default_post_request(ticket, settings[:path]) do |request, ticket|
        if settings[:x_on_behalf_of?]
          set_x_on_behalf_of(request, ticket)
        else
          set_requester_email(ticket)
        end
      end
    end
    
    def log_get(req, resp, id)
      log(">>#{id}:")
      log("Request:")
      req.each {|key, val| log(key + ' = ' + val)}
      log("Response:")
      log("Code: = " + resp.code)
      log("Message = " + resp.message)
      resp.each {|key, val| log(key + ' = ' + val)}
      log(resp.body)
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