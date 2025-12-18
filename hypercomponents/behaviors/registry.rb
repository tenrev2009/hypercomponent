# frozen_string_literal: true

module HyperComponents
  module Behaviors
    module Registry
      @map = {}

      class << self
        def register(key, klass = nil, &block)
          k = key.to_s
          @map[k] = klass || block
          @map[k]
        end

        def get(key)
          @map[key.to_s]
        end

        def build(key, *args)
          entry = get(key)
          return nil unless entry

          if entry.is_a?(Class)
            entry.new(*args)
          elsif entry.respond_to?(:call)
            entry.call(*args)
          end
        end

        def all
          @map.dup
        end

        # Appelé par core/lifecycle.rb
        def load_builtins!
          require_relative "loader"
          HyperComponents::Behaviors::Loader.load_builtins!
        end
      end
    end
  end
end


