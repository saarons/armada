# coding: UTF-8

module Armada
  module Callbacks
    extend ActiveSupport::Concern
    
    CALLBACKS = [
      :before_validation, :after_validation,
      :before_save,       :after_save,       :around_save,
      :before_create,     :after_create,     :around_create,
      :before_update,     :after_update,     :around_update,
      :before_destroy,    :after_destroy,    :around_destroy
    ]
    
    included do
      %w(create_or_update valid? create update destroy).each do |method|
        alias_method_chain method, :callbacks
      end
      extend ActiveModel::Callbacks
      define_callbacks :validation, :terminator => "result == false", :scope => [:kind, :name]
      define_model_callbacks :save, :create, :update, :destroy
    end
    
    module ClassMethods
      def before_validation(*args, &block)
        options = args.last
        if options.is_a?(Hash) && options[:on]
          options[:if] = Array(options[:if])
          options[:if] << "@_on_validate == :#{options[:on]}"
        end
        set_callback(:validation, :before, *args, &block)
      end
 
      def after_validation(*args, &block)
        options = args.extract_options!
        options[:prepend] = true
        options[:if] = Array(options[:if])
        options[:if] << "!halted && value != false"
        options[:if] << "@_on_validate == :#{options[:on]}" if options[:on]
        set_callback(:validation, :after, *(args << options), &block)
      end
    end
    
    def valid_with_callbacks?
      @_on_validate = new_record? ? :create : :update
      _run_validation_callbacks do
        valid_without_callbacks?
      end
    end
 
    def destroy_with_callbacks
      _run_destroy_callbacks do
        destroy_without_callbacks
      end
    end
    
    private
    def create_or_update_with_callbacks
      _run_save_callbacks do
        create_or_update_without_callbacks
      end
    end
 
    def create_with_callbacks
      _run_create_callbacks do
        create_without_callbacks
      end
    end
 
    def update_with_callbacks(*args)
      _run_update_callbacks do
        update_without_callbacks(*args)
      end
    end
    
  end
end