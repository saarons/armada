# coding: UTF-8

module Armada
  class ServerError < StandardError
    attr_reader :query
    def initialize(query)
      @query = query
    end
  end
  
  class ConnectionError < StandardError
  end
  
  class RecordNotFound < StandardError
  end
  
  class RecordNotSaved < StandardError
  end
end