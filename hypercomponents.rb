\
# frozen_string_literal: true

require 'sketchup.rb'
require 'extensions.rb'

module HyperComponents
  PLUGIN_ID = 'hypercomponents'
  PLUGIN_NAME = 'HyperComponents'
  DICT = 'hypercomponents'
  SCHEMA_VERSION = 1

  def self.root
    @root ||= File.dirname(__FILE__)
  end

  def self.lib_path(*parts)
    File.join(root, 'hypercomponents', *parts)
  end

  unless file_loaded?(__FILE__)
    ext = SketchupExtension.new(PLUGIN_NAME, 'hypercomponents/core/lifecycle')
    ext.description = 'HyperComponents — parametric components runtime (MVP).'
    ext.version     = File.read(File.join(root, 'VERSION')).strip rescue '0.1.0'
    ext.copyright   = '© HyperComponents'
    ext.creator     = 'HyperComponents'
    Sketchup.register_extension(ext, true)
    file_loaded(__FILE__)
  end
end
