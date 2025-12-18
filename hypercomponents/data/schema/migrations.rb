\
# frozen_string_literal: true

module HyperComponents
  module Data
    module Schema
      module Migrations
        def self.migrate_record(record)
          # Phase 1: only schema_version=1 exists.
          record
        end
      end
    end
  end
end
