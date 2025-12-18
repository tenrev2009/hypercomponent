\
# frozen_string_literal: true

module HyperComponents
  module Expressions
    class ParseError < StandardError
      attr_reader :pos
      def initialize(message, pos = nil)
        super(message)
        @pos = pos
      end
    end
  end
end
