# coding: UTF-8

module Armada
  mattr_reader :connection
  
  class Connection
    def initialize(host, port, password)
      @host     = host
      @port     = port
      @password = password
      connect
    end
    
    def connect
      begin
        @socket = TCPSocket.new(@host, @port)
        @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        query(["auth", @password]) if @password
      rescue
        raise Armada::ConnectionError, "could not connect"
      end
    end
    
    def query(q)
      request = ActiveSupport::JSON.encode(q)
      @socket.write(request << "\r\n")
      status, value = ActiveSupport::JSON.decode(@socket.gets)
      status == 0 ? value : raise(Armada::ServerError.new(request),value)
    end  
  end
  
  def self.setup!(spec = {})
    return @@connection if @@connection
    config = { address: "127.0.0.1", port: 3400 }.merge!(spec)
    @@connection = Connection.new(config[:address], config[:port], config[:password])
  end
  
  def self.compact!
    query_if_connection("compact")
  end
  
  def self.list_collections
    query_if_connection("list-collections")
  end
  
  def self.explain(query)
    query_if_connection("explain", query)
  end
  
  private
  def self.query_if_connection(*query)
    @@connection && @@connection.query(query)
  end
end