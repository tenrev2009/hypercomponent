\
# frozen_string_literal: true

require_relative 'functions'
require_relative 'diagnostics'

module HyperComponents
  module Expressions
    class Evaluator
      def initialize(value_resolver)
        @resolve = value_resolver # lambda: (scope_obj, param_id) -> value
      end

      # ctx = { self: entity, parent: entity_or_nil, children: {alias=>entity} }
      def eval(ast, ctx)
        t = ast['t']
        case t
        when 'num' then ast['v'].to_f
        when 'str' then ast['v'].to_s
        when 'bool' then !!ast['v']
        when 'var'
          @resolve.call(ctx[:self], ast['n'])
        when 'obj'
          case ast['n']
          when 'self' then ctx[:self]
          when 'Parent' then ctx[:parent]
          else ctx[:self]
          end
        when 'get'
          obj = eval(ast['o'], ctx)
          return nil unless obj
          @resolve.call(obj, ast['a'])
        when 'call'
          name = ast['n']
          # Special: Child("Alias") returns object
          if name == 'Child'
            alias_name = eval(ast['args'][0], ctx).to_s
            return (ctx[:children] || {})[alias_name]
          end
          args = ast['args'].map { |a| eval(a, ctx) }
          Functions.call(name, args)
        when 'un'
          v = eval(ast['e'], ctx)
          case ast['op']
          when '+' then v.to_f
          when '-' then -v.to_f
          when 'not' then !truthy?(v)
          else v
          end
        when 'bin'
          l = eval(ast['l'], ctx)
          r = eval(ast['r'], ctx)
          op = ast['op']
          case op
          when '+' then l.to_f + r.to_f
          when '-' then l.to_f - r.to_f
          when '*' then l.to_f * r.to_f
          when '/' then l.to_f / r.to_f
          when '^' then l.to_f**r.to_f
          when 'and' then truthy?(l) && truthy?(r)
          when 'or' then truthy?(l) || truthy?(r)
          when '==' then l == r
          when '!=' then l != r
          when '<' then l.to_f < r.to_f
          when '<=' then l.to_f <= r.to_f
          when '>' then l.to_f > r.to_f
          when '>=' then l.to_f >= r.to_f
          else
            raise ArgumentError, "Unknown operator '#{op}'"
          end
        else
          raise ArgumentError, "Unknown AST node '#{t}'"
        end
      end

      private

      def truthy?(v)
        v == true || (v.is_a?(Numeric) ? v != 0 : !(v.nil? || v == false || v.to_s.empty?))
      end
    end
  end
end
