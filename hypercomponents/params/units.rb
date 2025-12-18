\
# frozen_string_literal: true

module HyperComponents
  module Params
    module Units
      MM_PER_INCH = 25.4

      def self.to_mm(value, unit)
        v = value.to_f
        case unit.to_s.downcase
        when 'mm' then v
        when 'cm' then v * 10.0
        when 'm'  then v * 1000.0
        when 'in', 'inch' then v * MM_PER_INCH
        else v
        end
      end

      def self.from_mm(mm, unit)
        v = mm.to_f
        case unit.to_s.downcase
        when 'mm' then v
        when 'cm' then v / 10.0
        when 'm'  then v / 1000.0
        when 'in', 'inch' then v / MM_PER_INCH
        else v
        end
      end
    end
  end
end
