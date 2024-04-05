# frozen_string_literal: true

module Bp3
  module String
    # TableControllerMap provides for mappings between tables and controllers
    class TableControllerMap
      include Subclassable

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
        hash = {}
        ActiveRecord::Base.descendants.each do |model|
          table_name = model.table_name
          next if table_name.blank?

          table_name = model.name.tableize.tr('/', '_') if sti_subclass?(model)
          controller_name = "#{model.name.pluralize}Controller"
          hash[table_name] = controller_name
          hash[table_name.singularize] = controller_name
        end
        hash
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
