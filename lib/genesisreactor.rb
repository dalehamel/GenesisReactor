require 'find'

Find.find(File.join(File.dirname(File.dirname(__FILE__)), 'lib')) do |f|
  $LOAD_PATH << f if File.directory? f
end

require 'genesis_reactor'
