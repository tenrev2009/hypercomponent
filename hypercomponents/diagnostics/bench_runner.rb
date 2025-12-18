\
# frozen_string_literal: true

require_relative 'logger'
require_relative 'timeline'

module HyperComponents
  module Diagnostics
    module BenchRunner
      def self.run(label = 'bench')
        tl = Timeline.new
        yield tl
        Logger.info("[HC][BENCH] #{label}: #{tl.to_h.inspect}")
        tl.to_h
      end
    end
  end
end
