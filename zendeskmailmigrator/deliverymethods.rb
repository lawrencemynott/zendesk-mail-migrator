require 'zendeskmailmigrator/deliverymethods/basedelivery'

module ZendeskMailMigrator
  
  autoload :XMLFileDelivery, 'zendeskmailmigrator/deliverymethods/xmlfiledelivery'
  autoload :JSONFileDelivery, 'zendeskmailmigrator/deliverymethods/jsonfiledelivery'
  autoload :XMLDelivery, 'zendeskmailmigrator/deliverymethods/xmldelivery'
  autoload :JSONDelivery, 'zendeskmailmigrator/deliverymethods/jsondelivery'
  
end