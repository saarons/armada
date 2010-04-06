# coding: UTF-8

module Armada
  class Observer < ActiveModel::Observer
    class_attribute :observed_methods
    self.observed_methods = []

    def initialize
      super
      observed_subclasses.each { |klass| add_observer!(klass) }
    end

    def self.method_added(method)
      self.observed_methods += [method] if Armada::Callbacks::CALLBACKS.include?(method.to_sym)
    end

    protected
      def observed_subclasses
        observed_classes.sum([]) { |klass| klass.send(:subclasses) }
      end

      def add_observer!(klass)
        super
        
        self.class.observed_methods.each do |method|
          callback = :"_notify_observers_for_#{method}"
          if (klass.instance_methods & [callback, callback.to_s]).empty?
            klass.class_eval "def #{callback}; notify_observers(:#{method}); end"
            klass.send(method, callback)
          end
        end
      end
  end
end
