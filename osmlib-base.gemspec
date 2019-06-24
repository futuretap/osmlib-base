# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "osm"

Gem::Specification.new do |s|
  s.name = 'osmlib-base'
  s.version = OSM::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Jochen Topf', 'Serge Wroclawski']
  s.description = 'Basic support for OpenStreetMap data model (Nodes, Ways, Relations and Tags). Parsing of OSM XML files. Access to OpenStreetMap API.'
  s.summary = s.description
  s.email = 'jochen@topf.org'
  s.license = 'Public Domain'
  s.files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  s.executables = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency('rgeo')
end