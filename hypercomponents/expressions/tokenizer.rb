\
# frozen_string_literal: true

require_relative 'diagnostics'

module HyperComponents
  module Expressions
    Token = Struct.new(:type, :text, :pos)

    class Tokenizer
      KEYWORDS = %w[and or not true false].freeze

      def initialize(src)
        @src = src.to_s
        @i = 0
      end

      def tokens
        out = []
        while (t = next_token)
          out << t
          break if t.type == :eof
        end
        out
      end

      private

      def next_token
        skip_ws
        return Token.new(:eof, '', @i) if eof?

        ch = peek
        start = @i

        # number
        if ch =~ /[0-9.]/
          txt = read_number
          return Token.new(:number, txt, start)
        end

        # identifier / keyword
        if ch =~ /[A-Za-z_]/
          txt = read_ident
          type = KEYWORDS.include?(txt.downcase) ? txt.downcase.to_sym : :ident
          return Token.new(type, txt, start)
        end

        # string
        if ch == '"' || ch == "'"
          txt = read_string
          return Token.new(:string, txt, start)
        end

        # operators / punctuation
        two = @src[@i, 2]
        if %w[<= >= == !=].include?(two)
          @i += 2
          return Token.new(:op, two, start)
        end

        if %w[+ - * / ^ < > ( ) , .].include?(ch)
          @i += 1
          ttype = %w[( ) , .].include?(ch) ? ch.to_sym : :op
          return Token.new(ttype, ch, start)
        end

        raise ParseError.new("Unexpected character '#{ch}'", start)
      end

      def skip_ws
        @i += 1 while !eof? && peek =~ /\s/
      end

      def eof?
        @i >= @src.length
      end

      def peek
        @src[@i]
      end

      def read_number
        start = @i
        seen_dot = false
        while !eof?
          c = peek
          if c == '.'
            break if seen_dot
            seen_dot = true
            @i += 1
          elsif c =~ /[0-9]/
            @i += 1
          else
            break
          end
        end
        @src[start...@i]
      end

      def read_ident
        start = @i
        @i += 1 while !eof? && peek =~ /[A-Za-z0-9_]/
        @src[start...@i]
      end

      def read_string
        quote = peek
        @i += 1
        start = @i
        while !eof? && peek != quote
          @i += 1
        end
        raise ParseError.new('Unterminated string', start - 1) if eof?
        txt = @src[start...@i]
        @i += 1
        txt
      end
    end
  end
end
