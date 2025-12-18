\
# frozen_string_literal: true

require_relative '../base_contract'
require_relative '../registry'

module HyperComponents
  module Behaviors
    module Builtins
      class Transform < Base
        ID = 'transform'

        # Settings:
        # - apply_scale_from_params: false by default (unsafe for SmartSize workflows)
        # - base_transform_key: payload key for baseline transform (default: "base_transform")
        def apply(instance, ctx)
          settings = ctx[:behavior_settings] || {}
          return unless settings['apply_scale_from_params']

          vs = ctx[:value_store]
          target_w = vs.get('W').to_f
          target_d = vs.get('D').to_f
          target_h = vs.get('H').to_f

          inst_payload = ctx[:instance_payload]
          key = (settings['base_transform_key'] || 'base_transform').to_s
          base_arr = inst_payload[key]

          unless base_arr.is_a?(Array) && base_arr.length == 16
            base_arr = instance.transformation.to_a
            inst_payload[key] = base_arr
          end

          bb = instance.definition.bounds
          cur_w = axis_len(bb, :x)
          cur_d = axis_len(bb, :y)
          cur_h = axis_len(bb, :z)

          sx = safe_ratio(target_w, cur_w)
          sy = safe_ratio(target_d, cur_d)
          sz = safe_ratio(target_h, cur_h)

          base_tr = Geom::Transformation.new(base_arr)
          scale_tr = Geom::Transformation.scaling(sx, sy, sz)
          instance.transformation = base_tr * scale_tr
        end

        private

        def axis_len(bb, axis)
          case axis
          when :x then (bb.max.x - bb.min.x).abs
          when :y then (bb.max.y - bb.min.y).abs
          when :z then (bb.max.z - bb.min.z).abs
          else 1.0
          end
        end

        def safe_ratio(target, current)
          c = current.to_f
          return 1.0 if c <= 1e-9
          target.to_f / c
        end
      end
    end
  end
end

HyperComponents::Behaviors::Registry.register(HyperComponents::Behaviors::Builtins::Transform::ID,
                                             HyperComponents::Behaviors::Builtins::Transform)
