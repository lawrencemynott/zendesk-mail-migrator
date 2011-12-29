module ZendeskMailMigrator
  
  def self.defaults(&block)
    ZendeskMessageMigrator.instance.instance_eval(&block)
  end
  
  def self.delivery_method
    ZendeskMessageMigrator.instance.delivery_method
  end
  
  def self.retriever_method
    ZendeskMessageMigrator.instance.retriever_method
  end
  
  def self.conversion_method
    ZendeskMessageMigrator.instance.conversion_method
  end
  
  def self.migrate(*args)
    ZendeskMessageMigrator.instance.migrate(*args)
  end
  
  def self.migrateAll(*args)
    ZendeskMessageMigrator.instance.migrateAll(*args)
  end
  
  def self.migrateFirst(*args)
    ZendeskMessageMigrator.instance.migrateFirst(*args)
  end
  
end