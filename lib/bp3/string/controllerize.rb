# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module Bp3
  module String
    module Controllerize
      def controllerize
        TableControllerMap.hash[self] || "#{classify.pluralize}Controller"
      end
    end
  end
end
