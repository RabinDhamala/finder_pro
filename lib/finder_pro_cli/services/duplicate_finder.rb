# frozen_string_literal: true

module FinderProCli
  module Services
    class DuplicateFinder
      def self.find_duplicates(clients)
        grouped = clients.group_by(&:email)
        grouped.select { |_, list| list.size > 1 }
      end
    end
  end
end
