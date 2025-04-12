# frozen_string_literal: true

module FinderPro
  module Services
    module Pagination
      def self.paginate(array, page, per_page)
        start_index = (page - 1) * per_page
        array[start_index, per_page] || []
      end
    end
  end
end
