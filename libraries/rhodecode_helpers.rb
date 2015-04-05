module Rhodecode
  class Helpers
    class << self

      # Loads the given data bag.  The databag can be encrypted or unencrypted.
      def load_data_bag(data_bag, name)
        raw_hash = Chef::DataBagItem.load(data_bag, name)
        encrypted = raw_hash.detect do |key, value|
          if value.is_a?(Hash)
            value.has_key?("encrypted_data")
          end
        end
        if encrypted
          secret = Chef::EncryptedDataBagItem.load_secret
          Chef::EncryptedDataBagItem.new(raw_hash, secret)
        else
          raw_hash
        end
      end
    end
  end
end
