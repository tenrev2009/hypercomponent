\
# frozen_string_literal: true

require_relative '../base_contract'
require_relative '../registry'

module HyperComponents
  module Behaviors
    module Builtins
      class Materials < Base
        ID = 'materials'

        def apply(instance, ctx)
          settings = ctx[:behavior_settings] || {}
          p = (settings['material_param'] || 'Finish').to_s
          vs = ctx[:value_store]
          mat_name = vs.get(p).to_s.strip
          return if mat_name.empty?

          model = instance.model
          mat = model.materials[mat_name] || model.materials.add(mat_name)
          instance.material = mat
        end
      end
    end
  end
end

HyperComponents::Behaviors::Registry.register(HyperComponents::Behaviors::Builtins::Materials::ID,
                                             HyperComponents::Behaviors::Builtins::Materials)
