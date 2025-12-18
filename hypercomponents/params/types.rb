\
# frozen_string_literal: true

module HyperComponents
  module Params
    module Types
      SUPPORTED = %w[number integer string boolean enum color material file_path].freeze

      def self.cast(type, value)
        case type.to_s
        when 'number' then value.to_f
        when 'integer' then value.to_i
        when 'boolean'
          if value == true || value.to_s.downcase == 'true' || value.to_s == '1'
            true
          else
            false
          end
        else
          value.to_s
        end
      end
    end
  end
end
