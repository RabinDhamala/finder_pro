# frozen_string_literal: true

require 'json'
require_relative '../models/client'

module FinderProCli
  module Services
    class ClientLoader
      def self.load(file_path)
        data = JSON.parse(File.read(file_path))
        data.map do |client_hash|
          Models::Client.new(
            id: client_hash['id'],
            full_name: client_hash['full_name'],
            email: client_hash['email']
          )
        end
      end
    end
  end
end
