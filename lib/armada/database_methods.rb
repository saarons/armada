# coding: UTF-8

module Armada
  module DatabaseMethods
    extend ActiveSupport::Concern
    
    included do
      singleton_class.alias_method_chain :inherited, :collection_name
    end
    
    module ClassMethods
      def collection_name(name = nil)
        name ? (@collection_name = name) : @collection_name
      end
      
      private
      def instantiate(attributes)
        record = self.allocate
        record.instance_variable_set(:@attributes, attributes.with_indifferent_access)
        record.instance_variable_set(:@new_record, false)
        record
      end
      
      def inherited_with_collection_name(subclass)
        subclass.collection_name(subclass.model_name.plural)
        inherited_without_collection_name(subclass)
      end

    end
    
  end
end