\
# frozen_string_literal: true

require 'json'
require 'zlib'
require 'base64'
require 'time'

require_relative '../diagnostics/logger'
require_relative '../diagnostics/timeline'
require_relative 'transactions'
require_relative 'observers'
require_relative '../data/storage'
require_relative '../params/value_store'
require_relative '../expressions/compilation_cache'
require_relative '../rules/constraints_engine'
require_relative '../rules/automation_engine'
require_relative '../rules/variants_engine'
require_relative '../solver/incremental_solver'
require_relative '../behaviors/registry'
require_relative '../ui/dialog_controller'
require_relative '../interop/identity'

module HyperComponents
  module Core
    module Lifecycle
      @started = false

      def self.start
        return if @started
        @started = true

        Diagnostics::Logger.info('[HC] Starting...')
        Behaviors::Registry.load_builtins!

        Observers.install!

        UI::DialogController.install_menu!
        UI::DialogController.ensure_singleton!

        Diagnostics::Logger.info('[HC] Ready.')
      rescue => e
        Diagnostics::Logger.error("[HC] Startup failed: #{e.class}: #{e.message}\n#{e.backtrace&.join("\n")}")
        raise
      end

      def self.shutdown
        return unless @started
        @started = false
        Observers.uninstall!
      end
    end
  end
end

# Auto-start when file is loaded by SketchUp
HyperComponents::Core::Lifecycle.start
