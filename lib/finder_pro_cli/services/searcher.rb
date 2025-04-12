# frozen_string_literal: true

module FinderProCli
  module Services
    class Searcher
      def self.search(clients, field, query)
        return [] if query.strip.empty?

        clients.select do |client|
          value = begin
            client.send(field)
          rescue StandardError
            nil
          end
          value&.to_s&.downcase&.include?(query.downcase)
        end
      end
    end
  end
end
