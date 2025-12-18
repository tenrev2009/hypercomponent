\
# frozen_string_literal: true

require_relative 'diagnostics'
require_relative 'tokenizer'

module HyperComponents
  module Expressions
    module AST
      def self.num(v)   = { 't' => 'num', 'v' => v.to_f }
      def self.str(v)   = { 't' => 'str', 'v' => v.to_s }
      def self.bool(v)  = { 't' => 'bool', 'v' => !!v }
      def self.var(n)   = { 't' => 'var', 'n' => n.to_s }
      def self.obj(n)   = { 't' => 'obj', 'n' => n.to_s } # self/Parent
      def self.get(o,a) = { 't' => 'get', 'o' => o, 'a' => a.to_s }
      def self.call(n,args) = { 't' => 'call', 'n' => n.to_s, 'args' => args }
      def self.un(op,e)= { 't' => 'un', 'op' => op.to_s, 'e' => e }
      def self.bin(op,l,r)= { 't' => 'bin', 'op' => op.to_s, 'l' => l, 'r' => r }
    end

    class Parser
      def initialize(src)
        @tokens = Tokenizer.new(src).tokens
        @k = 0
      end

      def parse
        e = parse_or
        expect(:eof)
        e
      end

      private

      def cur = @tokens[@k]
      def accept(type, text = nil)
        return false if cur.type != type
        return false if text && cur.text != text
        @k += 1
        true
      end

      def expect(type, text = nil)
        t = cur
        ok = accept(type, text)
        return if ok
        raise ParseError.new("Expected #{text || type}, got #{t.type} '#{t.text}'", t.pos)
      end

      # Precedence: or > and > equality > comparison > term > factor > power > unary > primary

      def parse_or
        left = parse_and
        while accept(:or)
          right = parse_and
          left = AST.bin('or', left, right)
        end
        left
      end

      def parse_and
        left = parse_equality
        while accept(:and)
          right = parse_equality
          left = AST.bin('and', left, right)
        end
        left
      end

      def parse_equality
        left = parse_comparison
        while cur.type == :op && %w[== !=].include?(cur.text)
          op = cur.text
          @k += 1
          right = parse_comparison
          left = AST.bin(op, left, right)
        end
        left
      end

      def parse_comparison
        left = parse_term
        while cur.type == :op && %w[< <= > >=].include?(cur.text)
          op = cur.text
          @k += 1
          right = parse_term
          left = AST.bin(op, left, right)
        end
        left
      end

      def parse_term
        left = parse_factor
        while cur.type == :op && %w[+ -].include?(cur.text)
          op = cur.text
          @k += 1
          right = parse_factor
          left = AST.bin(op, left, right)
        end
        left
      end

      def parse_factor
        left = parse_power
        while cur.type == :op && %w[* /].include?(cur.text)
          op = cur.text
          @k += 1
          right = parse_power
          left = AST.bin(op, left, right)
        end
        left
      end

      def parse_power
        left = parse_unary
        while cur.type == :op && cur.text == '^'
          op = cur.text
          @k += 1
          right = parse_unary
          left = AST.bin(op, left, right)
        end
        left
      end

      def parse_unary
        if cur.type == :op && %w[+ -].include?(cur.text)
          op = cur.text
          @k += 1
          return AST.un(op, parse_unary)
        end
        if accept(:not)
          return AST.un('not', parse_unary)
        end
        parse_primary
      end

      def parse_primary
        t = cur
        if accept(:number)
          return AST.num(t.text)
        end
        if accept(:true)
          return AST.bool(true)
        end
        if accept(:false)
          return AST.bool(false)
        end
        if accept(:string)
          return AST.str(t.text)
        end
        if accept(:ident)
          name = t.text
          node = if %w[self Parent].include?(name)
                   AST.obj(name)
                 else
                   # Could be function call or var
                   if accept(:'(')
                     args = []
                     unless accept(:')')
                       loop do
                         args << parse_or
                         break if accept(:')')
                         expect(:',')
                       end
                     end
                     AST.call(name, args)
                   else
                     AST.var(name)
                   end
                 end

          # property access chain
          while accept(:'.')
            prop = cur
            expect(:ident)
            node = AST.get(node, prop.text)
          end
          return node
        end
        if accept(:'(')
          e = parse_or
          expect(:')')
          return e
        end
        raise ParseError.new("Unexpected token #{t.type} '#{t.text}'", t.pos)
      end
    end
  end
end
