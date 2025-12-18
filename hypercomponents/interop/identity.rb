# frozen_string_literal: true

require 'securerandom'
require_relative '../data/storage'

module HyperComponents
  module Interop
    module Identity
      def self.ensure_instance_guid!(instance)
        # On lit la structure complète via le nouveau Storage
        data = Data::Storage.read(instance)
        
        # L'ID se trouve maintenant dans 'meta' -> 'id'
        # Data::Storage.read garantit que 'meta' existe.
        guid = data['meta']['id'].to_s

        if guid.empty?
          guid = SecureRandom.uuid
          data['meta']['id'] = guid
          
          # On sauvegarde la structure mise à jour
          Data::Storage.write(instance, data)
        end
        
        guid
      end
    end
  end
end