# frozen_string_literal: true

require_relative '../base_contract'
require_relative '../registry'

module HyperComponents
  module Behaviors
    module Builtins
      class Arrays < Base
        ID = 'arrays'
        # Phase 2
      end
    end
  end
end

HyperComponents::Behaviors::Registry.register(HyperComponents::Behaviors::Builtins::Arrays::ID,
                                             HyperComponents::Behaviors::Builtins::Arrays)
