# frozen_string_literal: true

module HyperComponents
  module Tools
    module SelectionHelpers
      def self.selected_hc_instances(model = Sketchup.active_model)
        # Utilise la nouvelle méthode .smart? du Storage
        model.selection.to_a.select { |e| HyperComponents::Data::Storage.smart?(e) }
      end
    end
  end
end
