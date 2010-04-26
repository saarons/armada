# coding: UTF-8

module Armada
  module Validations
    extend ActiveSupport::Concern
    
    class UniquenessValidator < ActiveModel::EachValidator
      
      def validate_each(record, attribute, value)
        relation = record.class.where(attribute => value)
        
        Array.wrap(options[:scope]).each do |scope_attribute|
          relation = relation.where(scope_attribute => record.attributes[scope_attribute])
        end
        
        relation = relation.where(:id => {"!=" => record.id}) if record.persisted?
        
        return if relation.count == 0
        record.errors.add(attribute, :taken, :default => options[:message], :value => value)
      end
      
    end
  end
  
  module ClassMethods
    # Configuration options:
    # * <tt>:message</tt> - Specifies a custom error message (default is: "has already been taken").
    # * <tt>:scope</tt> - One or more columns by which to limit the scope of the uniqueness constraint.
    # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
    # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).
    # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
    # occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The
    # method, proc or string should return or evaluate to a true or false value.
    # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
    # not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The
    # method, proc or string should return or evaluate to a true or false value.
    def validates_uniqueness_of(*attr_names)
      validates_with UniquenessValidator, _merge_attributes(attr_names)
    end
  end
end