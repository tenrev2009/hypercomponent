\
# frozen_string_literal: true

module HyperComponents
  module Expressions
    module Functions
      def self.call(name, args)
        n = name.to_s.downcase
        case n
        when 'min' then args.map(&:to_f).min
        when 'max' then args.map(&:to_f).max
        when 'abs' then args[0].to_f.abs
        when 'round' then args[0].to_f.round((args[1] || 0).to_i)
        when 'floor' then args[0].to_f.floor
        when 'ceil' then args[0].to_f.ceil
        when 'clamp'
          v = args[0].to_f
          lo = args[1].to_f
          hi = args[2].to_f
          [[v, lo].max, hi].min
        when 'mm' then args[0].to_f
        when 'cm' then args[0].to_f * 10.0
        when 'm'  then args[0].to_f * 1000.0
        when 'in' then args[0].to_f * 25.4
        else
          raise ArgumentError, "Unknown function '#{name}'"
        end
      end
    end
  end
end
