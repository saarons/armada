# coding: UTF-8

module Armada
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::Dirty
    
    included do
      [:create_or_update, :write_attribute].each do |method|
        alias_method_chain method, :dirty
      end
    end
    
    private
    def write_attribute_with_dirty(attribute_name, value)
      send("#{attribute_name}_will_change!") if persisted?
      write_attribute_without_dirty(attribute_name, value)
    end
    
    def create_or_update_with_dirty
      if status = create_or_update_without_dirty
        @previously_changed = changes
        changed_attributes.clear
      else
        changed.each { |attribute_name| send("reset_#{attribute_name}!") } if persisted?
      end
      status
    end
    
    def serializable_changes
      changed.inject({}) { |h, a| h[a] = @attributes[a]; h }
    end
    
  end
end