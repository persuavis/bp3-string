# frozen_string_literal: true

require 'active_record'

module Bp3
  module String
    # TableModelMap provides for mappings between tables and models
    class TableModelMap
      include Subclassable

      @cached_hash = nil
      CACHED_HASH_MUTEX = Mutex.new

      def self.testing?
        Rails.env.test?
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
        enc = 'string'.encoding # TODO: not sure why encoding sometimes doesn't match
        hash = {}
        ActiveRecord::Base.descendants.each do |model|
          table_name = model.table_name
          next if table_name.blank?

          table_name = table_name.split('.').last # remove the schema
          model_name = determine_model_name(model).encode(enc)
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

      def self.hash
        cached_hash
      end

      def hash
        self.class.hash
      end
    end
  end
end
