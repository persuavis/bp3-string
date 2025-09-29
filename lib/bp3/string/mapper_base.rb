# frozen_string_literal: true

module Bp3
  module String
    # MapperBase provides the base class for controller and model mappings
    class MapperBase
      include Subclassable

      # override in testing if needed
      def self.testing?
        false
      end

      def self.reset_cached_hash
        raise(NotImplementedError, 'Must implement in subclass')
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

      private

      def sti_subclass?(model)
        self.class.sti_subclass?(model)
      end

      def subclassed?(model)
        self.class.subclassed?(model)
      end
    end
  end
end
