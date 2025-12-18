\
# frozen_string_literal: true

require_relative '../../diagnostics/logger'

module HyperComponents
  module Data
    module Integrity
      module IncidentsLog
        def self.log(entity, cause)
          id = begin
            entity.respond_to?(:persistent_id) ? entity.persistent_id : entity.object_id
          rescue
            entity.object_id
          end
          Diagnostics::Logger.warn("[HC][DATA] Incident entity=#{id} cause=#{cause}")
        end
      end
    end
  end
end
