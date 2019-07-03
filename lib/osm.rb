%w(api objects database stream_parser).each do |filename|
  require File.join( File.dirname(__FILE__), 'osm', filename )
end

module OSM
    VERSION = '0.1.6'
end
