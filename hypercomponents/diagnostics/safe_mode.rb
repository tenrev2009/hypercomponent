\
# frozen_string_literal: true

require_relative 'logger'

module HyperComponents
  module Diagnostics
    module SafeMode
      @enabled = false

      def self.enable!
        @enabled = true
        Logger.warn('[HC] SafeMode enabled (auto-update disabled).')
      end

      def self.enabled? = @enabled
    end
  end
end
