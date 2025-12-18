# frozen_string_literal: true

require_relative '../base_contract'
require_relative '../registry'

module HyperComponents
  module Behaviors
    module Builtins
      class Labels < Base
        ID = 'labels'
        # Phase 2
      end
    end
  end
end

HyperComponents::Behaviors::Registry.register(HyperComponents::Behaviors::Builtins::Labels::ID,
                                             HyperComponents::Behaviors::Builtins::Labels)
