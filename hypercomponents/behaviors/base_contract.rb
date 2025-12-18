\
# frozen_string_literal: true

module HyperComponents
  module Behaviors
    class Base
      def id = self.class::ID
      def validate(_instance, _ctx) = []
      def apply(_instance, _ctx) = nil
      def dependencies = []
      def outputs = []
      def mutates = []
    end
  end
end
