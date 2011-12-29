module ZendeskMailMigrator
  module Utilities
    
    LOG_FILENAME = "email_import_#{Time.now.strftime("%Y%m%d_%H%M%S")}.log"
    
    def repeat_every(interval)
      loop do
        start_time = Time.now
        yield
        elapsed = Time.now - start_time
        sleep([interval - elapsed, 0].max)
      end
    end
    
    def log(message)
      @log ||= File.open(LOG_FILENAME, "a+")
      @log << message + "\n"
      @log.flush
    end
    
  end
end