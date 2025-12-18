\
# frozen_string_literal: true

require_relative 'types'
require_relative 'units'
require_relative '../data/storage'
require_relative '../diagnostics/logger'

module HyperComponents
  module Params
    class ValueStore
      def initialize(def_payload, inst_payload)
        @def = def_payload
        @inst = inst_payload
        @overrides = (@inst['overrides'] ||= {})
        @computed  = (@inst['computed']  ||= {})
      end

      def def_params = (@def['params'] ||= {})
      def expressions = (@def['expressions'] ||= {})

      def get(id)
        id = id.to_s
        if @overrides.key?(id)
          @overrides[id]
        elsif @computed.key?(id)
          @computed[id]
        else
          meta = def_params[id] || {}
          meta['default']
        end
      end

      def set_override(id, value)
        id = id.to_s
        meta = def_params[id] || {}
        type = meta['type'] || 'string'
        unit = meta['unit_display']

        v = Types.cast(type, value)
        v = Units.to_mm(v, unit) if unit && type == 'number'
        @overrides[id] = v
      end

      def set_computed(id, value)
        id = id.to_s
        @computed[id] = value
      end

      def computed?(id)
        expressions.key?(id.to_s)
      end

      def export_for_ui
        out = {}
        def_params.each do |id, meta|
          type = meta['type'] || 'string'
          unit = meta['unit_display']
          v = get(id)
          v_ui = (unit && type == 'number') ? Units.from_mm(v, unit) : v
          out[id] = {
            'value' => v_ui,
            'type' => type,
            'unit' => unit,
            'group' => meta['group'],
            'order' => meta['order'],
            'min' => meta['min'],
            'max' => meta['max'],
            'description' => meta['description']
          }
        end
        out
      end
    end
  end
end
