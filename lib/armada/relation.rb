# coding: UTF-8

module Armada
  module RelationMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      RELATION_METHODS = %w(all)
      QUERY_OPTIONS    = %w(where offset order limit only distinct)
      QUERY_METHODS    = %w(insert select delete count multi_read multi_write checked_write create_index drop_index list_indexes)
      
      def relation
        Armada::Relation.new(self)
      end
      
      delegate(*(QUERY_METHODS + QUERY_OPTIONS + RELATION_METHODS), :to => :relation)
      
    end
    
  end
  
  class Relation
    FIND_OPTIONS_KEYS = %w(where offset order limit only distinct)
    
    # undefine :select to avoid bugs/confusion with Kernel.select
    # ...true story
    undef_method :select
    
    def initialize(superclass)
      @superclass = superclass
      @join = "and"
    end
    
    def where(conditions)
      where = []
      conditions.each_pair do |attribute, value|
        if value.is_a?(Hash)
           value.each_pair do |operator, val|
             where << [operator, attribute, build_condition_value(val)]
           end
        else
          where << build_condition(attribute, value)  
        end
      end
      where = where.size > 1 ? where.unshift("and") : where.first
      @where = if option_defined?(:where)
        if @join == @where.first && @where.first == where.first
          @where.concat(where.from(1))
        elsif @join == @where.first && !is_conjunction?(where.first)
          @where << where
        elsif @join == where.first && is_conjunction?(@where.first)
          @where.tap { |w| w[-1] = ([@join] << w.last).concat(where.from(1)) }
        elsif @join == where.first && !is_conjunction?(@where.first)
          where.insert(1,@where)
        elsif @join == "and" && @where.first == "or" && !is_conjunction?(where.first) && !is_conjunction?(@where.last.first)
          @where.tap { |w| w[-1] = [@join] << w.last << where }
        elsif @join == "and" && @where.first == "or" && !is_conjunction?(where.first) && is_conjunction?(@where.last.first)
          @where.tap { |w| w[-1] << where }
        else
          [@join] << @where << where
        end
      else
        where
      end
      @join = "and"
      self
    end
    
    def or
      raise(ArgumentError, "Missing 'where' condition") unless option_defined?(:where)
      @join = "or"
      self
    end
    
    def offset(value)
      @offset = value
      self
    end
    
    def limit(value)
      @limit = value
      self
    end
    
    def order(*attributes)
      options = attributes.extract_options!
      
      attributes.flatten!
      attributes.map! do |attribute|
        attribute.is_a?(Array) ? attribute : [attribute, :asc]
      end
      
      order = attributes.concat(options.to_a).tap do |order|
        order.flatten! if order.size == 1
      end
      
      @order = if option_defined?(:order)
        @order = [@order] unless @order.first.is_a?(Array)
        order.first.is_a?(Array) ? @order.concat(order) : @order << order
      else
        order
      end
      self
    end
    
    def only(*attributes)
      attributes.flatten!
      @only = if option_defined?(:only)
        Array.wrap(@only).concat(attributes)
      else
        attributes.size == 1 ? attributes.first : attributes
      end
      self
    end
    
    def distinct
      @distinct = true
      self
    end
    
    def to_query(method = nil, *args, &block)
      method ? send("generate_#{method}_query", *args, &block) : find_options
    end
    
    def all
      results = self.select
      return results if option_defined?(:only)
      results.map { |record| @superclass.send(:instantiate, record) }
    end
    delegate :first, :last, :to => :all
    
    private
    
    def method_missing(method, *args, &block)
      method = method.to_s
      if %w(create_index drop_index).include?(method)
        singleton_class.send(:define_method, method) do
          raise(ArgumentError, "Missing 'order' condition") unless option_defined?(:order)
          query(to_query(method, @order)) == 1
        end.call
      elsif %w(delete count update insert select checked_write multi_read multi_write list_indexes).include?(method)
        singleton_class.send(:define_method, method) do |*args, &block|
          query(to_query(method, *args, &block))
        end.call(*args, &block)
      else
        super
      end
    end
    
    def generate_list_indexes_query
      ["list-indexes", collection_name]
    end
    
    def generate_create_index_query(order)
      ["create-index", collection_name, order]
    end
    
    def generate_drop_index_query(order)
      ["drop-index", collection_name, order]
    end
    
    def generate_multi_read_query(read_queries = [], &block)
      yield read_queries if block_given?
      ["multi-read", read_queries]
    end
    
    def generate_multi_write_query(queries = [], &block)
      yield queries if block_given?
      ["multi-write", queries]
    end
    
    def generate_checked_write_query(read_query, expected_result, write_query)
      ["checked-write", read_query, expected_result, write_query]
    end
    
    def generate_delete_query
      ["delete", collection_name].tap do |q|
        q << find_options if find_options?
      end
    end
    
    def generate_update_query(changes)
      ["update", collection_name, changes, find_options]
    end
    
    def generate_insert_query(records)
      ["insert", collection_name].tap do |q|
        q << (records.size == 1 ? records.first : records)
      end
    end
    
    def generate_count_query
      ["count", collection_name].tap do |q|
        q << find_options if find_options?
      end
    end
    
    def generate_select_query
      ["select", collection_name].tap do |q|
        q << find_options if find_options?
      end
    end
    
    def is_conjunction?(value)
      %w(and or).include?(value)
    end
    
    def option_defined?(option)
      instance_variable_defined?("@#{option}")
    end
    
    def find_options?
      FIND_OPTIONS_KEYS.any? { |x| option_defined?(x) }
    end
    
    def find_options
      FIND_OPTIONS_KEYS.dup.inject({}) do |h1, x|
        option_defined?(x) ? h1.tap { |h2| h2[x.to_sym] = instance_variable_get("@#{x}") } : h1
      end
    end
    
    def collection_name
      @collection_name ||= if @superclass.is_a?(String)
        @superclass
      else
        @superclass.collection_name
      end
    end
    
    def query(args)
      Armada.connection.query(args)
    end
    
    def build_condition(attribute, value)
      operator = case value
        when Array then "in"
        when Range then ">=<="
        else "="
      end
      [operator, attribute, build_condition_value(value)]
    end
    
    def build_condition_value(value)
      case value
        when Range           then [value.first, value.last]
        when Time, DateTime  then value.to_i
        else value
      end
    end
    
    
  end
end