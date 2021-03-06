# coding: UTF-8

module Armada
  module Timestamp
    extend ActiveSupport::Concern
 
    included do
      alias_method_chain :create, :timestamps
      alias_method_chain :update, :timestamps
 
      class_attribute :record_timestamps
      self.record_timestamps = true
    end
    
    def touch(attribute = nil)
      current_time = current_time_from_current_timezone
 
      if attribute
        write_attribute(attribute, current_time)
      else
        write_attribute('updated_at', current_time) if respond_to?(:updated_at)
        write_attribute('updated_on', current_time) if respond_to?(:updated_on)
      end
 
      save!
    end
 
    private
    def create_with_timestamps
      if self.class.record_timestamps?
        current_time = current_time_from_current_timezone
    
        write_attribute('created_at', current_time) if respond_to?(:created_at) && created_at.nil?
        write_attribute('created_on', current_time) if respond_to?(:created_on) && created_on.nil?
        
        write_attribute('updated_at', current_time) if respond_to?(:updated_at) && updated_at.nil?
        write_attribute('updated_on', current_time) if respond_to?(:updated_on) && updated_on.nil?
      end
    
      create_without_timestamps
    end
    
    def update_with_timestamps(*args)
      if self.class.record_timestamps? && changed?
        current_time = current_time_from_current_timezone
    
        write_attribute('updated_at', current_time) if respond_to?(:updated_at)
        write_attribute('updated_on', current_time) if respond_to?(:updated_on)
      end
    
      update_without_timestamps(*args)
    end
    
    def current_time_from_current_timezone
      Time.zone.now.to_i
    end
  end
end