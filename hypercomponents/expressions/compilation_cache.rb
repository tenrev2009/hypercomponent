\
# frozen_string_literal: true

require_relative 'parser_ast'
require_relative 'diagnostics'

module HyperComponents
  module Expressions
    module CompilationCache
      @cache = {} # { definition_persistent_id => { expr_string => ast } }

      def self.for_definition(definition)
        did = definition.persistent_id rescue definition.object_id
        @cache[did] ||= {}
      end

      def self.compile(definition, expr_string)
        key = expr_string.to_s
        c = for_definition(definition)
        return c[key] if c.key?(key)
        ast = Parser.new(key).parse
        c[key] = ast
        ast
      end

      def self.clear_for_definition(definition)
        did = definition.persistent_id rescue definition.object_id
        @cache.delete(did)
      end
    end
  end
end
