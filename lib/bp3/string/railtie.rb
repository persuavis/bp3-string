# frozen_string_literal: true

require 'rails/railtie'

module Bp3
  module String
    class Railtie < Rails::Railtie
      initializer 'bp3.string.railtie.register' do |app|
        app.config.after_initialize do
          class ::String
            include Bp3::String::Modelize
            include Bp3::String::Controllerize
          end
        end

        app.config.to_prepare do
          if defined?(Bp3::String::TableModelMap)
            Bp3::String::TableModelMap.reset_cached_hash
          end
          if defined?(Bp3::String::TableControllerMap)
            Bp3::String::TableControllerMap.reset_cached_hash
          end
        end
      end
    end
  end
end
