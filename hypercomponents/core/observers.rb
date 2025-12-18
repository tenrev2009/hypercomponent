\
# frozen_string_literal: true

require_relative '../diagnostics/logger'
require_relative '../ui/dialog_controller'
require_relative '../interop/identity'

module HyperComponents
  module Core
    module Observers
      @installed = false
      @selection_observer = nil
      @entities_observer = nil

      class SelectionObserver < Sketchup::SelectionObserver
        def onSelectionBulkChange(selection)
          HyperComponents::UI::DialogController.refresh_if_open
        end
      end

      class EntitiesObserver < Sketchup::EntitiesObserver
        def onElementAdded(entities, entity)
          return unless entity.is_a?(Sketchup::ComponentInstance) || entity.is_a?(Sketchup::Group)
          # Assign InstanceGUID when an HC instance is created/duplicated
          if HyperComponents::Data::Storage.hc_instance?(entity)
            HyperComponents::Interop::Identity.ensure_instance_guid!(entity)
          end
        rescue => e
          HyperComponents::Diagnostics::Logger.warn("[HC] EntitiesObserver error: #{e.class}: #{e.message}")
        end
      end

      def self.install!
        return if @installed
        @installed = true

        model = Sketchup.active_model
        @selection_observer = SelectionObserver.new
        model.selection.add_observer(@selection_observer)

        @entities_observer = EntitiesObserver.new
        model.entities.add_observer(@entities_observer)

        Diagnostics::Logger.debug('[HC] Observers installed.')
      rescue => e
        Diagnostics::Logger.error("[HC] Failed to install observers: #{e.class}: #{e.message}")
      end

      def self.uninstall!
        return unless @installed
        @installed = false

        model = Sketchup.active_model
        model.selection.remove_observer(@selection_observer) if @selection_observer
        model.entities.remove_observer(@entities_observer) if @entities_observer
      rescue
        # no-op
      ensure
        @selection_observer = nil
        @entities_observer = nil
      end
    end
  end
end
