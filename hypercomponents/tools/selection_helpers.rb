# frozen_string_literal: true

module HyperComponents
  module Tools
    module SelectionHelpers
      def self.selected_hc_instances(model = Sketchup.active_model)
        model.selection.to_a.select { |e| HyperComponents::Data::Storage.hc_instance?(e) }
      end
    end
  end
end
