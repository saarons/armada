require File.join(File.dirname(__FILE__),'spec_helper.rb')
 
describe "A bank instance" do
  before do
    Bank.delete
    @bank = Bank.new(:name => "Wells Fargo", :rank => 4)
  end
  
  after do
    Bank.delete
  end
  
  it "has read accessors" do
    @bank.name.should == "Wells Fargo"
    @bank.attributes[:name].should == "Wells Fargo"
  end
  
  it "has write accessors" do
    @bank.name = "Citigroup"
    @bank.name.should == "Citigroup"
    @bank.attributes[:name].should == "Citigroup"
  end
  
  it "is comparable to other banks" do
    @bank.should == Bank.new(:name => "Wells Fargo", :rank => 4)
  end
  
  context "that is unsaved" do
    it "is new" do
      @bank.new_record?.should be_true
    end
    
    it "is not persisted" do
      @bank.persisted?.should be_false
    end
    
    it "can not be destroyed" do
      @bank.destroy.should be_false
    end
  end
  
  context "that is valid" do
    it "will save" do
      @bank.save.should be_true
    end
    
    it "will save!" do
      lambda { @bank.save! }.should be_true
    end
  end
  
  context "that is invalid" do
    before do
      @bank.rank = 5
    end
    
    it "will not save" do
      @bank.save.should be_false
    end
    
    it "will not save!" do
      lambda { @bank.save! }.should raise_error Armada::RecordNotSaved
    end
  end
  
  context "that is saved" do
    before do
      @bank.save
    end
    
    it "is persisted" do
      @bank.persisted?.should be_true
    end
    
    it "can be destroyed" do
      @bank.destroy.should be_true
      @bank.destroyed?.should be_true
    end
    
    it "can be changed" do
      @bank.name = "Citigroup"
      @bank.rank = 2
      @bank.save.should be_true
    end
    
    it "will retain previous value after a failed update" do
      @bank.rank = 5
      @bank.save.should be_false
      @bank.rank.should == 4
    end
    
  end
end