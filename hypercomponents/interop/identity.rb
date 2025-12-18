\
# frozen_string_literal: true

require 'securerandom'
require_relative '../data/storage'

module HyperComponents
  module Interop
    module Identity
      def self.ensure_instance_guid!(instance)
        payload = Data::Storage.instance_payload(instance)
        guid = payload['instance_guid'].to_s
        if guid.empty?
          guid = SecureRandom.uuid
          payload['instance_guid'] = guid
          Data::Storage.write_payload_object(instance, payload, kind: :instance)
        end
        guid
      end
    end
  end
end
