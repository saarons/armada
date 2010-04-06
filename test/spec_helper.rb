$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__),'..','vendor')

require "pp"
require "spec"
require "armada"

Time.zone = "UTC"

Armada.setup!

class Bank < Armada::Model
  add_columns :name, :created_at, :updated_at, :rank, :price, :public
  validates :rank, :inclusion => {:in => 1..4}, :uniqueness => true
end

Spec::Runner.configure do |config|
  config.before(:each, :type => :model) do
    Bank.delete
    
    @bac = Bank.new(:name => "Bank of America", :rank => 1, :price => 16.24, :public => true)
    @c   = Bank.new(:name => "Citigroup",       :rank => 2, :price =>  3.56, :public => true)
    @wfc = Bank.new(:name => "Wells Fargo",     :rank => 4, :price => 28.89, :public => true)
    
    [@bac, @c, @wfc].each { |x| x.save }
  end
  config.after(:each, :type => :model) do
    Bank.delete
  end
end