
= OSM Library - Base

A library for handling OpenStreetMap data.

== License

This work is released into the public domain. This applies worldwide.
In case this is not legally possible, any entity is granted the right
to use this work for any purpose, without any conditions, unless such
conditions are required by law.

== Author

Jochen Topf <jochen@topf.org>
Serge Wroclawski <serge+osmlib@wroclawski.org>

== Web

For more information see the OSM Library home page at
http://osmlib.rubyforge.org/ or the Rubyforge project page at
http://rubyforge.org/projects/osmlib/ . The OpenStreetMap project can
be found at http://www.openstreetmap.org/ .

== Dependencies

* RGeo (gem install rgeo)
* libxml-ruby (optional C-based XML parser, needs reasonably new version)
  (Debian/Ubuntu: libxml-ruby1.8)
* xmlparser (optional C-based XML parser) (Debian/Ubuntu: libxml-parser-ruby1.8)
* builder (Debian/Ubuntu: libbuilder-ruby1.8)

Dependencies are not all installed automatically when installing the gem
packages because this breaks when the packages are already installed as
Debian packages.

== Usage

=== Basic OSM Objects

The library provides classes for the three basic building blocks of any
OSM database: OSM::Node, OSM::Way, and OSM::Relation. They are all subclasses
of OSM::OSMObject.

  # support for basic OSM objects
  require 'osm'

  # create a node
  node = OSM::Node.new(17, 'user', '2007-10-31T23:48:54Z', 7.4, 53.2)

  # create a way and add a node
  way = OSM::Way.new(1743, 'user', '2007-10-31T23:51:17Z')
  way.nodes << node

  # create a relation
  relation = OSM::Relation.new(331, 'user', '2007-10-31T23:51:53Z')

There is also an OSM::Member class for members of a relation:

  # create a member and add it to a relation
  member = OSM::Member.new('way', 1743, 'role')
  relation << [member]

Tags can be added to Nodes, Ways, and Relations:

  way.add_tags('highway' => 'residential', 'name' => 'Main Street')

You can get the hash of tags like this:

  way.tags
  way.tags['highway']
  way.tags['name'] = 'Bay Street'

As a convenience tags can also be accessed with their name only:
  way.highway

This is implemented with the method_missing() function. Of course it
only works for tag keys which are allowed as ruby method names.

There is also an OSM::Change object which can be used to store
OSM data as it would appear in an OSMChange file.

  change = OSM::Change.new

OSM::Change objects consist of OSM::Action objects, which contain a
single action as well as one or more Node, Way or Relation. An action
must be created with an action keyword :create, :modify, or :delete)

  node = OSM::Node.new(17, 'user', '2007-10-31T23:48:54Z', 7.4, 53.2)
  action = OSM::Action.new(:create)
  action.push(node)

OSM::Change objects have two relevant methods, .actions, which returns
an Array of OSM::Actions, and objects, which returns all the objects
in all the actions.

   actions = change.actions
   objects = change.objects

=== Accessing the OSM API

You can access the OSM RESTful web API through the OSM::API class
and through some methods in the OSM::Node, OSM::Way, and OSM::Relation
classes.

There are methods for getting Nodes, Ways, and Relations by ID,
getting the history of an object etc.

Currently only read access is implemented, write access will follow
in a later version.

See the OSM::API class for details.

=== The Stream Parser

To parse an OSM XML file create a subclass of OSM::Callbacks and
define the methods node(), way(), and relation() in it:

  class MyCallbacks < OSM::Callbacks

    def node(node)
       ...
    end

    def way(way)
       ...
    end

    def relation(relation)
       ...
    end

  end

Instantiate an object of this class and give it to a OSM::StreamParser:

  require 'osm'

  cb = MyCallbacks.new
  parser = OSM::StreamParser.new(:filename => 'filename.osm', :callbacks => cb)
  parser.parse

The methods node(), way(), or relation() will be called whenever
the parser has parsed a complete node, way, or relation (i.e. after
all tags, nodes in a way, or members of a relation are available).

There are several parser options available:

* REXML (Default, slow, works on all machines, because it is part
  of the Ruby standard distribution)
* Libxml (Based on the C libxml2 library, faster than REXML, new
  version needed, sometimes hard to install)
* Expat (Based on C Expat library, faster than REXML)

Since version 0.1.3 REXML is the default parser because many people
had problems with the C-based parser. Change the parser by setting
the environment variable OSMLIB_XML_PARSER to the parser you want
to use (before you require 'osm'):

From the shell:
    export OSMLIB_XML_PARSER=Libxml

From ruby:
    ENV['OSMLIB_XML_PARSER']='Libxml'
    require 'osm'

=== Using a Database

If you want the parser to keep track of all the objects it finds in
the XML file you can create a OSM::Database for it:

  require 'osm'

  db = OSM::Database.new

The database lives in memory so this works only if the XML file is
not too big.

When creating the parser you can give it the database object:

  parser = OSM::StreamParser.new(:filename => 'filename.osm', :db => db)

In your node(), way(), and relation() methods you now have to return
+true+ if you want this object to be stored in the database and +false+
otherwise. This gives you a very simple filtering mechanism. If you
are only interested in pharmacies, you can use this code:

  def node(node)
    return true if node.amenity == 'pharmacy'
    false
  end

After the whole file has been parsed, all nodes with
<tt>amenity=pharmacy</tt> will be available through the database.
All other objects have been thrown away. You can get a hash of
all nodes (key is id, value is a Node object) with:

  db.nodes

Or single nodes with the ID:

  db.get_node(1839)

Ways and relations are accessed the same way.

When deleting a database call

  db.clear

first. This will break the internal loop references and makes sure
that the garbage collector can free the memory.

== More examples

For more examples see the examples directory.

== Testing

Call 'rake test' to run tests. You can change the XML parser the
tests should use by setting the OSMLIB_XML_PARSER environment
variable:

  OSMLIB_XML_PARSER=REXML rake test  # (default)
  OSMLIB_XML_PARSER=Libxml rake test
  OSMLIB_XML_PARSER=Expat rake test

