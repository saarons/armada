# coding: UTF-8

module Armada
  module AttributeMethods
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
    
    included do
      attr_reader :attributes
      class_attribute :columns
      self.columns = [:id]
      ["", "="].each { |x| attribute_method_suffix(x) }
    end
    
    module ClassMethods
      def add_columns(*cols)
        self.columns = (self.columns + cols.map(&:to_sym)).uniq
      end
      alias :add_column :add_columns
      
      def remove_columns(*cols)
        self.columns = (self.columns - cols.map(&:to_sym).delete_if { |x| x == :id })
      end
      alias :remove_column :remove_columns
      
      def define_attribute_methods
        super(self.columns)
      end
    end
    
    def write_attribute(attribute_name, value)
      attribute_name = attribute_name.to_s
      if !persisted? || attribute_name != "id"
        @attributes[attribute_name] = value
      else
        @attributes["id"]
      end
    end
    
    def read_attribute(attribute_name)
      @attributes[attribute_name]
    end
    
    def attributes=(attributes)
      attributes.each_pair { |k, v| send("#{k}=",v) }
      @attributes
    end
    
    def method_missing(method_id, *args, &block)
      if !self.class.attribute_methods_generated?
        self.class.define_attribute_methods
        method_name = method_id.to_s
        guard_private_attribute_method!(method_name, args)
        send(method_id, *args, &block)
      else
        super
      end
    end
 
    def respond_to?(*args)
      self.class.define_attribute_methods
      super
    end
    
    private
    def attribute=(attribute_name, value)
      write_attribute(attribute_name, value)
    end
    
    def attribute(attribute_name)
      read_attribute(attribute_name)
    end
    alias :read_attribute_for_validation :attribute
    
  end
end
