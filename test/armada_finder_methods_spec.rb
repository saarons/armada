require File.join(File.dirname(__FILE__),'spec_helper.rb')
 
describe Bank, :type => :model do
  it "has a collection name" do
    Bank.collection_name.should == "banks"
  end
  
  it "will find banks" do
    Bank.find(@bac.id).should == @bac
    Bank.find([@bac.id]).should == [@bac]
    Bank.find(@wfc.id, @c.id).should == [@wfc, @c]
    Bank.find(@wfc.id, @c.id, @bac.id).should == [@wfc, @c, @bac]
  end
  
  it "will raise an error when it does not find a bank" do
    lambda { Bank.find("481516") }.should raise_error Armada::RecordNotFound
  end
end