# frozen_string_literal: true

require "sketchup.rb"
require "json"
require "securerandom"
require "time"

module HyperComponents
  module Data
    module Storage
      DICT = "smart_component".freeze

      META_KEY     = "meta".freeze
      FEATURES_KEY = "features".freeze
      STATE_KEY    = "state".freeze

      SCHEMA_VERSION = 1
      DEFAULT_UNITS  = "mm".freeze

      # --------- Public API ---------

      def self.smart?(entity)
        return false unless supported_entity?(entity)
        meta = safe_parse_json(entity.get_attribute(DICT, META_KEY), {})
        meta.is_a?(Hash) && !meta["id"].to_s.strip.empty?
      rescue
        false
      end

      def self.ensure!(entity)
        return nil unless supported_entity?(entity)
        data = read(entity)
        write(entity, data)
        data
      end

      def self.read(entity)
        raise ArgumentError, "Unsupported entity" unless supported_entity?(entity)

        meta     = safe_parse_json(entity.get_attribute(DICT, META_KEY), {})
        features = safe_parse_json(entity.get_attribute(DICT, FEATURES_KEY), {})
        state    = safe_parse_json(entity.get_attribute(DICT, STATE_KEY), {})

        meta     = default_meta(entity)     unless meta.is_a?(Hash) && !meta.empty?
        features = default_features         unless features.is_a?(Hash) && !features.empty?
        state    = default_state            unless state.is_a?(Hash) && !state.empty?

        migrate!(meta)

        { "meta" => meta, "features" => features, "state" => state }
      end

      def self.write(entity, data)
        raise ArgumentError, "Unsupported entity" unless supported_entity?(entity)

        meta     = data["meta"]     || {}
        features = data["features"] || {}
        state    = data["state"]    || {}

        entity.set_attribute(DICT, META_KEY,     dump_json(meta))
        entity.set_attribute(DICT, FEATURES_KEY, dump_json(features))
        entity.set_attribute(DICT, STATE_KEY,    dump_json(state))
      end

      def self.patch!(entity, patch_hash, reason = "patch")
        raise ArgumentError, "Unsupported entity" unless supported_entity?(entity)
        patch_hash = {} unless patch_hash.is_a?(Hash)

        data = read(entity)
        data = deep_merge(data, patch_hash)
        mark_dirty!(data, reason)
        write(entity, data)
        data
      end

      def self.mark_dirty!(data, reason = nil)
        data["state"] ||= {}
        data["state"]["dirty"] = true
        data["state"]["debug"] ||= {}
        data["state"]["debug"]["dirty_reason"] = reason if reason
        data
      end

      def self.clear_dirty!(entity)
        data = read(entity)
        data["state"]["dirty"] = false
        write(entity, data)
        data
      end

      # --------- Defaults ---------

      def self.default_meta(entity)
        {
          "id" => SecureRandom.uuid,
          "version" => SCHEMA_VERSION,
          "type" => "generic",
          "created_at" => Time.now.iso8601,
          "units" => DEFAULT_UNITS,
          "base_transform" => transform_to_a(entity.transformation)
        }
      end

      def self.default_features
        {
          "order" => ["position", "rotation", "dimension", "smart_size", "array", "configuration", "collision"],
          "enabled" => {
            "position" => true,
            "rotation" => true,
            "dimension" => true,
            "smart_size" => false,
            "array" => false,
            "configuration" => false,
            "collision" => false
          },
          "data" => {
            "position" => { "x" => 0.0, "y" => 0.0, "z" => 0.0, "lock" => { "x" => false, "y" => false, "z" => false }, "relative" => "parent" },
            "rotation" => { "rx" => 0.0, "ry" => 0.0, "rz" => 0.0, "mode" => "local" },
            "dimension" => { "mode" => "scale", "sx" => 1.0, "sy" => 1.0, "sz" => 1.0 },
            "smart_size" => { "axis" => "x", "target_length" => 1000.0, "left_fixed" => 50.0, "right_fixed" => 50.0, "scale_from_params" => false },
            "array" => { "mode" => "linear", "count_x" => 1, "count_y" => 1, "spacing_x" => 0.0, "spacing_y" => 0.0 },
            "configuration" => { "material" => "" },
            "collision" => { "mode" => "aabb", "enabled" => false }
          }
        }
      end

      def self.default_state
        { "dirty" => false, "errors" => [], "debug" => {}, "metrics" => {} }
      end

      def self.migrate!(meta)
        v = meta["version"].to_i
        return if v >= SCHEMA_VERSION
        meta["version"] = SCHEMA_VERSION
      end

      # --------- Helpers ---------

      def self.supported_entity?(e)
        e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
      end

      def self.safe_parse_json(str, default_hash)
        return default_hash if str.nil? || str.to_s.strip.empty?
        JSON.parse(str)
      rescue
        default_hash
      end

      def self.dump_json(hash)
        JSON.generate(hash)
      rescue
        "{}"
      end

      def self.deep_merge(a, b)
        out = (a || {}).dup
        (b || {}).each do |k, v|
          if out[k].is_a?(Hash) && v.is_a?(Hash)
            out[k] = deep_merge(out[k], v)
          else
            out[k] = v
          end
        end
        out
      end

      def self.transform_to_a(t)
        t.to_a.map(&:to_f) # 16 floats
      end
    end
  end
end
