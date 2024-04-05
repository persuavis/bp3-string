# frozen_string_literal: true

module Bp3
  module String
    # TableModelMap provides for mappings between tables and models
    class TableModelMap
      @cached_hash = nil
      CACHED_HASH_MUTEX = Mutex.new

      def self.cached_hash
        return build_hash if Rails.env.test?
        return @cached_hash if @cached_hash.present?

        CACHED_HASH_MUTEX.synchronize do
          return @cached_hash if @cached_hash.present?

          @cached_hash = build_hash
        end
      end

      def self.reset_cached_hash
        @cached_hash = nil
      end

      def self.build_hash
        enc = "string".encoding # TODO: not sure why encoding sometimes doesn't match
        hash = {}
        ActiveRecord::Base.descendants.each do |model|
          table_name = model.table_name
          next if table_name.blank?

          table_name = table_name.split('.').last # remove the schema
          model_name = determine_model_name(model).encode(enc)
          # puts "model_name for #{model.name} is #{model_name}"
          hash[table_name] = model_name
          hash[table_name.singularize] = model_name
        end
        hash
      end

      def self.determine_model_name(model)
        return determine_model_name(model.superclass) if sti_subclass?(model)
        return determine_model_name(model.descendants.first) if subclassed?(model)

        model.name
      end

      # look for any ancestors of *model* that share the same table name *and* the model
      # is an STI model, as determined by the presence of a 'type' columhn
      def self.sti_subclass?(model)
        table_name = model.table_name
        out = model.ancestors[1..].any? do |class_or_module|
          if class_or_module.is_a?(Module) && !class_or_module.is_a?(Class)
            false
          elsif class_or_module.table_name == table_name
            sti_model?(class_or_module)
          end
        rescue StandardError
          false
        end
        # puts "model #{model.name} as an STI subclass" if out
        out
      end

      def self.sti_model?(klass)
        klass.columns.map(&:name).any? { |name| name == 'type' }
      end

      def self.subclassed?(model)
        out = model.descendants.any? && !sti_model?(model)
        # puts "model #{model.name} has descendants and is not an STI model" if out
        out
      end

      def self.hash
        cached_hash
      end

      def hash
        self.class.hash
      end
    end
  end
end
