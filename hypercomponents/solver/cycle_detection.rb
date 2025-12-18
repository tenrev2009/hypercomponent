\
# frozen_string_literal: true

module HyperComponents
  module Solver
    module CycleDetection
      def self.detect_cycle(graph)
        visiting = {}
        visited = {}
        stack = []

        visit = lambda do |node|
          return nil if visited[node]
          if visiting[node]
            idx = stack.index(node) || 0
            return stack[idx..] + [node]
          end
          visiting[node] = true
          stack << node
          (graph[node] || []).each do |dep|
            cyc = visit.call(dep)
            return cyc if cyc
          end
          stack.pop
          visiting.delete(node)
          visited[node] = true
          nil
        end

        graph.keys.each do |n|
          cyc = visit.call(n)
          return cyc if cyc
        end
        nil
      end
    end
  end
end
