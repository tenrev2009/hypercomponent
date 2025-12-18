\
# frozen_string_literal: true

require_relative 'graph_builder'
require_relative 'cycle_detection'
require_relative '../expressions/evaluator'
require_relative '../expressions/compilation_cache'
require_relative '../diagnostics/logger'

module HyperComponents
  module Solver
    module IncrementalSolver
      def self.solve!(definition, value_store, ctx, resolver)
        exprs = value_store.expressions
        return if exprs.nil? || exprs.empty?

        graph = GraphBuilder.build(definition, exprs)
        cyc = CycleDetection.detect_cycle(graph)
        if cyc
          raise RuntimeError, "Cycle detected: #{cyc.join(' -> ')}"
        end

        order = topo_sort(graph)
        evaluator = Expressions::Evaluator.new(resolver)

        order.each do |param_id|
          expr = exprs[param_id]
          next unless expr
          ast = Expressions::CompilationCache.compile(definition, expr)
          v = evaluator.eval(ast, ctx)
          value_store.set_computed(param_id, v)
        end
      end

      def self.topo_sort(graph)
        indeg = Hash.new(0)
        graph.each do |n, deps|
          indeg[n] ||= 0
          deps.each { |d| indeg[n] += 1 if graph.key?(d) }
        end
        q = indeg.select { |_, v| v == 0 }.map(&:first)
        out = []
        until q.empty?
          n = q.shift
          out << n
          graph.each do |m, deps|
            next unless deps.include?(n)
            next unless graph.key?(m)
            indeg[m] -= 1
            q << m if indeg[m] == 0
          end
        end
        out
      end
    end
  end
end
