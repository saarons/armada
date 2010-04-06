require File.join(File.dirname(__FILE__),'spec_helper.rb')

describe Armada::Validations, :type => :model do
  it "should validate uniqueness of rank" do
    @wfc.rank = 2
    @wfc.save.should be_false
  end
  
  it "should not allow new records to intervene" do
    @jpm = Bank.new(:name => "JPMorgan Chase", :rank => 2, :price => 42.59, :public => true)
    @jpm.save.should be_false
  end
end