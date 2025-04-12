# frozen_string_literal: true

module FinderProCli
  module Services
    class ClientStore
      def self.load_from_file(path)
        @clients = ClientLoader.load(path)
      end

      def self.all
        @clients ||= []
      end

      def self.replace(new_clients)
        @clients = new_clients
      end
    end
  end
end
