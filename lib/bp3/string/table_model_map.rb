# frozen_string_literal: true

require 'active_record'

module Bp3
  module String
    # TableModelMap provides for mappings between tables and model class names
    class TableModelMap
      include Subclassable

      @cached_hash = nil
      CACHED_HASH_MUTEX = Mutex.new

      # override in testing if needed
      def self.testing?
        false
      end

      def self.cached_hash
        return build_hash if testing?
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
        new.build_hash
      end

      def self.hash
        cached_hash
      end

      def hash
        self.class.hash
      end

      def build_hash
        encoding = 'string'.encoding # TODO: not sure why encoding sometimes doesn't match
        hash = {}
        ActiveRecord::Base.descendants.each do |model|
          table_name = model.table_name
          next if table_name.blank?

          table_name = table_name.split('.').last # remove the schema
          model_name = determine_model_name(model).encode(encoding)
          hash[table_name] = model_name
          hash[table_name.singularize] = model_name
        end
        hash
      end

      def determine_model_name(model)
        return determine_model_name(model.superclass) if sti_subclass?(model)
        return determine_model_name(model.descendants.first) if subclassed?(model)

        model.name
      end

      def sti_subclass?(model)
        self.class.sti_subclass?(model)
      end

      def subclassed?(model)
        self.class.subclassed?(model)
      end
    end
  end
end
