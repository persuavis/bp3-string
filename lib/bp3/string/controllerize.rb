# frozen_string_literal: true

module Bp3
  module String
    module Controllerize
      def controllerize
        TableControllerMap.hash[self] || "#{classify}Controller"
      end
    end
  end
end
