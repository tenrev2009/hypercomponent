\
# frozen_string_literal: true

module HyperComponents
  module Data
    module Schema
      CURRENT = 1

      # Minimal validation for Phase 1 (strict JSON Schema can be added in Phase 2/3).
      def self.validate_record(record)
        return false unless record.is_a?(Hash)
        return false unless record['schema_version'].is_a?(Integer)
        return false if record['schema_version'] > CURRENT
        true
      end
    end
  end
end
