# frozen_string_literal: true

module Bp3
  module String
    module Modelize
      def modelize
        TableModelMap.hash[self] || classify
      end
    end
  end
end
