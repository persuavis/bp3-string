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
      end
    end
  end
end
