$LOAD_PATH << './'

module ZendeskMailMigrator
  
  require 'mail'
  require 'zendeskmailmigrator/utilities'
  require 'zendeskmailmigrator/zendeskmailmigrator'
  require 'zendeskmailmigrator/zendeskmessagemigrator'
  require 'zendeskmailmigrator/conversionmethods'
  require 'zendeskmailmigrator/deliverymethods'

end