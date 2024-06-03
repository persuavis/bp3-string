# frozen_string_literal: true

module Bp3
  module String
    module Subclassable
      extend ActiveSupport::Concern

      class_methods do
        # look for any ancestors of *model* that share the same table name *and* the model
        # is an STI model, as determined by the presence of a 'type' column
        def sti_subclass?(model)
          table_name = model.table_name
          model.ancestors[1..].any? do |class_or_module|
            if class_or_module.is_a?(Module) && !class_or_module.is_a?(Class)
              false
            elsif class_or_module.table_name == table_name
              sti_model?(class_or_module)
            end
          rescue StandardError
            false
          end
        end

        def sti_model?(klass)
          klass.columns.map(&:name).any? { |name| name == 'type' }
        end

        def subclassed?(model)
          model.descendants.any? && !sti_model?(model)
        end
      end
    end
  end
end
