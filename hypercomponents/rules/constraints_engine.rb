\
# frozen_string_literal: true

require_relative '../diagnostics/logger'

module HyperComponents
  module Rules
    module ConstraintsEngine
      def self.apply!(value_store)
        # Apply param metadata min/max clamps
        value_store.def_params.each do |id, meta|
          next unless meta.is_a?(Hash)
          next unless meta['type'].to_s == 'number'
          v = value_store.get(id)
          min = meta['min']
          max = meta['max']
          next if v.nil?
          vv = v.to_f
          vv = [vv, min.to_f].max if min
          vv = [vv, max.to_f].min if max
          value_store.set_override(id, vv) if value_store.instance_variable_get(:@overrides)&.key?(id) # keep overrides clamped
          value_store.set_computed(id, vv) if value_store.instance_variable_get(:@computed)&.key?(id)
        end
      end
    end
  end
end
