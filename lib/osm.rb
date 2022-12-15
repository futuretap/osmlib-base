%w(api objects database stream_parser version).each do |filename|
  require File.join( File.dirname(__FILE__), 'osm', filename )
end

