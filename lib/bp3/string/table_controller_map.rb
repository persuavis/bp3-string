# frozen_string_literal: true

module Bp3
  module String
    # TableControllerMap provides for mappings between table-like strings and controller class names
    class TableControllerMap
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
        @encoding = 'string'.encoding # TODO: not sure why encoding sometimes doesn't match
        @ar_hash = build_hash_from_active_record
        @ac_hash = build_hash_from_action_controller
        @ar_hash.merge(@ac_hash)
      end

      private

      attr_reader :ar_hash, :ac_hash, :encoding

      def build_hash_from_active_record
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

      def build_hash_from_action_controller
        hash = {}
        ActionController::Base.descendants.each do |controller|
          hash.merge!(build_hash_from_controller(controller))
        end
        hash
      end

      def build_hash_from_controller(controller)
        hash = {}
        if controller.descendants.empty?
          if controller.name.present?
            controller_name = controller.name.encode(encoding)
            tableish_name = controller_name.gsub(/Controller\z/, '').underscore.tr('/', '_').pluralize
            hash[tableish_name] = controller_name unless @ar_hash.key?(tableish_name)
            hash[tableish_name.singularize] = controller_name unless @ar_hash.key?(tableish_name.singularize)
          end
        else
          controller.descendants.each do |ctrlr|
            hash.merge!(build_hash_from_controller(ctrlr))
          end
        end
        hash
      end

      def sti_subclass?(model)
        self.class.sti_subclass?(model)
      end
    end
  end
end
