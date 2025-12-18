\
# frozen_string_literal: true

module HyperComponents
  module Diagnostics
    class Timeline
      Step = Struct.new(:name, :t0, :t1)

      def initialize
        @steps = []
      end

      def step(name)
        s = Step.new(name, Process.clock_gettime(Process::CLOCK_MONOTONIC), nil)
        yield
      ensure
        s.t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        @steps << s
      end

      def to_h
        @steps.map { |s| [s.name, ((s.t1 - s.t0) * 1000.0)] }.to_h
      end
    end
  end
end
