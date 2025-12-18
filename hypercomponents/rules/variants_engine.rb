\
# frozen_string_literal: true

require_relative '../expressions/compilation_cache'
require_relative '../expressions/evaluator'

module HyperComponents
  module Rules
    module VariantsEngine
      def self.apply!(definition, behaviors, rules, ctx, resolver)
        return behaviors if rules.nil? || rules.empty?

        evaluator = Expressions::Evaluator.new(resolver)
        out = behaviors.map(&:dup)

        rules.each do |rule|
          cond = rule['when']
          ok = true
          if cond && !cond.to_s.strip.empty?
            ast = Expressions::CompilationCache.compile(definition, cond)
            ok = !!evaluator.eval(ast, ctx)
          end
          next unless ok

          (rule['then'] || []).each do |act|
            case act['action']
            when 'enable_behavior'
              id = act['id'].to_s
              out.each { |b| b['enabled'] = true if b['id'].to_s == id }
            when 'disable_behavior'
              id = act['id'].to_s
              out.each { |b| b['enabled'] = false if b['id'].to_s == id }
            end
          end
        end

        out
      end
    end
  end
end
