# coding: UTF-8

module Armada
  module FinderMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      def find(*args)
        find_from_ids(args)
      end
      
      private
      def find_from_ids(ids)
        expects_array = ids.first.kind_of?(Array)
        return ids.first if expects_array && ids.first.empty?
 
        ids = ids.flatten.compact.uniq
 
        case ids.size
          when 0
            raise(Armada::RecordNotFound)
          when 1
            result = find_one(ids.first)
            expects_array ? [ result ] : result
          else
            find_some(ids)
        end
      end
      
      def find_one(id)
        result = self.where(:id => id).limit(1).first
        result.blank? ? raise(Armada::RecordNotFound) : result
      end
      
      def find_some(ids)
        results = self.where(:id => ids).all
        results.size == ids.size ? results : raise(Armada::RecordNotFound)
      end
      
    end 
  end
end