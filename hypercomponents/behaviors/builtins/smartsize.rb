\
# frozen_string_literal: true

require_relative '../base_contract'
require_relative '../registry'
require_relative '../../diagnostics/logger'

module HyperComponents
  module Behaviors
    module Builtins
      class SmartSize < Base
        ID = 'smartsize'

        def apply(instance, ctx)
          settings = ctx[:behavior_settings] || {}
          axis = (settings['axis'] || 'x').downcase
          target_param = (settings['target_param'] || 'W').to_s
          left_name  = settings['left']  || 'HC_ZONE_LEFT'
          mid_name   = settings['mid']   || 'HC_ZONE_MID'
          right_name = settings['right'] || 'HC_ZONE_RIGHT'

          vs = ctx[:value_store]
          target = vs.get(target_param).to_f

          # SmartSize requires per-instance definition edits:
          instance.make_unique if instance.definition.count_used_instances > 1

          defs = instance.definition.entities
          left  = find_zone(defs, left_name)
          mid   = find_zone(defs, mid_name)
          right = find_zone(defs, right_name)

          raise "SmartSize zones not found (#{left_name}, #{mid_name}, #{right_name})" unless left && mid && right

          mid_bb = mid.bounds
          total_bb = instance.definition.bounds

          cur_total = axis_len(total_bb, axis)
          cur_mid = axis_len(mid_bb, axis)
          raise 'SmartSize mid zone has zero length' if cur_mid <= 1e-6

          # Stretch mid to reach target total length (keeping left/right as-is).
          delta_total = target - cur_total
          return if delta_total.abs < 1e-6

          new_mid = cur_mid + delta_total
          raise 'SmartSize target too small for fixed zones' if new_mid <= 1e-6

          scale = new_mid / cur_mid

          # Scale mid around its local min corner (stable)
          origin = axis_min_point(mid_bb, axis)
          tr_scale = scaling_on_axis(origin, axis, scale)

          mid.transform!(tr_scale)

          # Move right by delta_total along axis
          tr_move = translation_on_axis(axis, delta_total)
          right.transform!(tr_move)

          Diagnostics::Logger.debug("[HC][SmartSize] axis=#{axis} target=#{target} cur=#{cur_total} delta=#{delta_total}")
        end

        private

        def find_zone(entities, name)
          entities.grep(Sketchup::Group).find { |e| e.name == name } ||
            entities.grep(Sketchup::ComponentInstance).find { |e| e.name == name }
        end

        def axis_len(bb, axis)
          case axis
          when 'x' then (bb.max.x - bb.min.x).abs
          when 'y' then (bb.max.y - bb.min.y).abs
          when 'z' then (bb.max.z - bb.min.z).abs
          else 0.0
          end
        end

        def axis_min_point(bb, axis)
          case axis
          when 'x' then Geom::Point3d.new(bb.min.x, bb.min.y, bb.min.z)
          when 'y' then Geom::Point3d.new(bb.min.x, bb.min.y, bb.min.z)
          when 'z' then Geom::Point3d.new(bb.min.x, bb.min.y, bb.min.z)
          else bb.min
          end
        end

        def scaling_on_axis(origin, axis, scale)
          case axis
          when 'x' then Geom::Transformation.scaling(origin, scale, 1.0, 1.0)
          when 'y' then Geom::Transformation.scaling(origin, 1.0, scale, 1.0)
          when 'z' then Geom::Transformation.scaling(origin, 1.0, 1.0, scale)
          else Geom::Transformation.new
          end
        end

        def translation_on_axis(axis, delta)
          v =
            case axis
            when 'x' then Geom::Vector3d.new(delta, 0, 0)
            when 'y' then Geom::Vector3d.new(0, delta, 0)
            when 'z' then Geom::Vector3d.new(0, 0, delta)
            else Geom::Vector3d.new(0, 0, 0)
            end
          Geom::Transformation.translation(v)
        end
      end
    end
  end
end

HyperComponents::Behaviors::Registry.register(HyperComponents::Behaviors::Builtins::SmartSize::ID,
                                             HyperComponents::Behaviors::Builtins::SmartSize)
