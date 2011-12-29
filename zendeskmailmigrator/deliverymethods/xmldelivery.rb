require "net/http"

module ZendeskMailMigrator
  
  class XMLDelivery
    include Utilities
    
    def initialize(values)
      self.settings = { :subdomain          => "lawrencetestsite.zendesk.com",
                        :path               => "/requests.xml",
                        :username           => "lawrence@zendesk.com",
                        :password           => "croc287",
                        :use_ssl?           => true,
                        :content_type       => "application/xml" }.merge!(values)
    end
    
    attr_accessor :settings
    
    def deliver(tickets)
      # 3 things to think about: limiting to 700 requests per minute, dealing with errors and logging
      # Do the api calls to create the tickets, currently limit api calls to 1 every 0.1 seconds which stays well within the 700 rpm rate limit
      protocol = settings[:use_ssl] ? "https" : "http"
      uri = URI.parse("#{protocol}://#{settings[:subdomain]}")

      http = Net::HTTP.new(uri.host, uri.port)

      # POST request
      req = build_post_request(tickets[0])
      resp = http.request(req)
      
      # Log results
      log_post(req, resp, 0)
      
      # Note on retrieving session cookie if request was successful
      # api seems to work by giving you a session cookie only useable for the thing you made a successful call for.
      # For example if the X-On-Behalf-Of user can't be authenticated the cookie won't work or if you make a successful Get call the
      # cookie will only authenticate you to submit to /tickets.xml not sure why this is at the moment.
      cookie = nil
      
      # POST remaining tickets limiting to 600 requests per minute using the session cookie for auth
      i=1
      repeat_every(0.1) do
        break if i==tickets.length
        if cookie.nil? and resp.code == "201"
          cookie = resp["set-cookie"] # see note above about the reason for this
        end
        req = build_post_request(tickets[i], cookie)
        resp = http.request(req)
        log_post(req, resp, i)
        i+=1
      end
    end
    
    def build_post_request(ticket, session_cookie = nil)
      request = Net::HTTP::Post.new(settings[:path])
      request.body = ticket[:doc].to_s
      if session_cookie.nil?
        request.basic_auth(settings[:username], settings[:password])
      else
        request["Cookie"] = session_cookie
      end
      request["Content-Type"] = settings[:content_type]
      request["X-On-Behalf-Of"] = ticket[:requester]
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