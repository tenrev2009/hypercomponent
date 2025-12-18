\
# frozen_string_literal: true

require_relative '../expressions/compilation_cache'

module HyperComponents
  module Solver
    module GraphBuilder
      # graph[param] = [dependencies]
      def self.build(definition, expressions)
        graph = {}
        expressions.each do |param_id, expr|
          deps = extract_deps(definition, expr)
          graph[param_id.to_s] = deps
        end
        graph
      end

      def self.extract_deps(definition, expr)
        ast = Expressions::CompilationCache.compile(definition, expr)
        deps = []
        walk = lambda do |node|
          t = node['t']
          if t == 'var'
            deps << node['n'].to_s
          elsif t == 'get'
            # self.W / Parent.H -> count dependency on attribute name
            deps << node['a'].to_s
            walk.call(node['o'])
          else
            %w[l r e o].each do |k|
              v = node[k]
              walk.call(v) if v.is_a?(Hash)
            end
            if node['args'].is_a?(Array)
              node['args'].each { |a| walk.call(a) }
            end
          end
        end
        walk.call(ast)
        deps.uniq
      rescue
        []
      end
    end
  end
end
