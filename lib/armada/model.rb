# coding: UTF-8

module Armada
  class Model
    include Armada::Validations
    extend  ActiveModel::Naming
    include Armada::FinderMethods
    include ActiveModel::Observing
    include Armada::DatabaseMethods
    include Armada::RelationMethods
    include ActiveModel::Conversion
    extend  ActiveModel::Translation
    include Armada::AttributeMethods
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Serializers::Xml
    include ActiveModel::Serializers::JSON
    
    def initialize(attributes = {})
      @attributes = {}.with_indifferent_access
      @new_record = true
      self.attributes = attributes
    end

    def new_record?
      @new_record || false
    end
    
    def destroy
      @destroyed = (persisted? && relation.delete == 1)
    end
    
    def destroyed?
      @destroyed || false
    end
    
    def persisted?
      !(new_record? || destroyed?)
    end
    
    def save
      create_or_update
    end
    
    def save!
      save || raise(Armada::RecordNotSaved)
    end
    
    def ==(other)
      klass = self.class
      case other
        when klass then klass.collection_name == other.class.collection_name && self.attributes == other.attributes
        else false
      end
    end
    
    protected
    def generate_unique_id
      self.id ||= rand(36**26).to_s(36)[0..24]
    end
    
    private
    def create_or_update
      (valid? && !destroyed?) && (new_record? ? create : update)
    end
    
    def create
      if status = (relation.insert(@attributes) == 1)
        @new_record = false
      end
      status
    end
    
    def update
      changed? && relation.update(serializable_changes) == 1
    end
    
    def relation
      @relation ? @relation.dup : @relation = Armada::Relation.new(self.class).where(:id => self.id)
    end
    
  end
end

Armada::Model.class_eval do
  include Armada::Dirty
  include Armada::Callbacks
  include Armada::Timestamp
  
  validates :id, :presence => true
  before_validation :generate_unique_id, :on => :create
end