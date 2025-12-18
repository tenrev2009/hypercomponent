\
# frozen_string_literal: true

require_relative 'base_contract'
require_relative 'builtins/transform'
require_relative 'builtins/smartsize'
require_relative 'builtins/materials'
require_relative 'builtins/arrays'
require_relative 'builtins/labels'

module HyperComponents
  module Behaviors
    module Loader
      def self.load_builtins
        # Requiring builtins registers them.
      end
    end
  end
end
