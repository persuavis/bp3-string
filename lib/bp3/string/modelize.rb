# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module Bp3
  module String
    module Modelize
      def modelize
        TableModelMap.hash[self] || classify
      end
    end
  end
end
