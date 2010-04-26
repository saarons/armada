# coding: UTF-8

require File.join(File.dirname(__FILE__),'spec_helper.rb')

describe Armada::Relation, :type => :model do
  
  it "will find all banks" do
    Bank.all.should =~ [@bac, @c, @wfc]
  end
  
  it "will implement select correctly" do
    Bank.select.should =~ [@bac, @c, @wfc].map { |x| x.attributes }
    Bank.where(:rank => 4).select.should == [@wfc.attributes]
  end
  
  it "will implement delete correctly" do
    Bank.where(:rank => 4).delete.should == 1
    Bank.delete.should == 2
  end
  
  it "will implement count correctly" do
    Bank.count.should == 3
    Bank.where(:rank => 4).count.should == 1
  end
  
  it "will implement where correctly" do
    Bank.where(:rank => 4).all.should == [@wfc]
    Bank.where(:rank => 1..2).all.should =~ [@bac, @c]
  end
  
  it "will implement order correctly" do
    Bank.order(:rank).all.should == [@bac, @c, @wfc]
    Bank.order(:rank => :asc).all.should  == [@bac, @c, @wfc]
    Bank.order(:rank => :desc).all.should == [@wfc, @c, @bac]
  end
  
  it "will implement limit correctly" do
    Bank.order(:rank => :desc).limit(1).all.should == [@wfc]
  end
  
  it "will implement offset correctly" do
    Bank.order(:rank => :desc).offset(1).all.should == [@c, @bac]
  end
  
  it "will implement only correctly" do
    Bank.order(:rank => :desc).only(:rank).all.should == [4,2,1]
    Bank.order(:rank => :desc).only(:rank, :name).all.should == [[4,"Wells Fargo"],[2,"Citigroup"],[1,"Bank of America"]]
  end
  
  it "will implement to_query correctly for #where" do
    Bank.where(:rank => 4).to_query.should == {where:["=", :rank, 4]}
    
    Bank.where(:rank => 4, :name => "Wells Fargo").to_query.should       == {where:["and",["=", :rank, 4],["=", :name, "Wells Fargo"]]}
    Bank.where(:rank => 4).where(:name => "Wells Fargo").to_query.should == {where:["and",["=", :rank, 4],["=", :name, "Wells Fargo"]]}
    
    Bank.where(:rank => 4).where(:name => "Wells Fargo").where(:id => 1).to_query.should == {where:["and",["=", :rank, 4],["=", :name, "Wells Fargo"],["=", :id, 1]]}
    Bank.where(:rank => 4, :name => "Wells Fargo").where(:id => 1).to_query.should       == {where:["and",["=", :rank, 4],["=", :name, "Wells Fargo"],["=", :id, 1]]}
    Bank.where(:rank => 4).where(:name => "Wells Fargo", :id => 1).to_query.should       == {where:["and",["=", :rank, 4],["=", :name, "Wells Fargo"],["=", :id, 1]]}
    
    Bank.where(:rank => 4, :name => "Wells Fargo").where(:id => 1, :created_at => {">" => 1}).to_query.should == {where:["and",["=", :rank, 4],["=", :name, "Wells Fargo"],["=", :id, 1],[">", :created_at, 1]]}
  end
  
  it "will implement to_query correctly for #where with \"or\" boolean matching" do
    Bank.where(:name => "Wells Fargo").or.where(:rank => 1).to_query.should == {where:["or",["=", :name, "Wells Fargo"],["=", :rank, 1]]}
    Bank.where(:name => "Citigroup").or.where(:rank => 1).or.where(:rank => 4).to_query.should == {where:["or", ["=", :name, "Citigroup"], ["=", :rank, 1], ["=", :rank, 4]]}
    
    Bank.where(:rank => 1).or.where(:rank => 4, :name => "Wells Fargo").to_query.should       == {where:["or",["=", :rank, 1], ["and", ["=", :rank, 4], ["=", :name, "Wells Fargo"]]]}
    Bank.where(:rank => 1).or.where(:rank => 4).where(:name => "Wells Fargo").to_query.should == {where:["or",["=", :rank, 1], ["and", ["=", :rank, 4], ["=", :name, "Wells Fargo"]]]}
    
    Bank.where(:name => "Wells Fargo", :rank => 4).or.where(:rank => 1).to_query.should == {where:["or",["and", ["=", :name, "Wells Fargo"], ["=", :rank, 4]],["=", :rank, 1]]}
    
    Bank.where(:name => "Wells Fargo", :rank => 4).or.where(:name => "Bank of America", :rank => 1).to_query.should       == {where:["or",["and", ["=", :name, "Wells Fargo"], ["=", :rank, 4]],["and", ["=", :name, "Bank of America"], ["=", :rank, 1]]]}
    Bank.where(:name => "Wells Fargo", :rank => 4).or.where(:name => "Bank of America").where(:rank => 1).to_query.should == {where:["or",["and", ["=", :name, "Wells Fargo"], ["=", :rank, 4]],["and", ["=", :name, "Bank of America"], ["=", :rank, 1]]]}
    
    Bank.where(:name => "Wells Fargo", :rank => 4).or.where(:name => "Bank of America").where(:rank => {"=" => 1, "!=" => 4}).to_query.should       == {where:["or",["and", ["=", :name, "Wells Fargo"], ["=", :rank, 4]],["and", ["=", :name, "Bank of America"], ["=", :rank, 1], ["!=", :rank, 4]]]}
    Bank.where(:name => "Wells Fargo", :rank => 4).or.where(:name => "Bank of America", :rank => 1).where(:rank => {"!=" => 4}).to_query.should     == {where:["or",["and", ["=", :name, "Wells Fargo"], ["=", :rank, 4]],["and", ["=", :name, "Bank of America"], ["=", :rank, 1], ["!=", :rank, 4]]]}
    Bank.where(:name => "Wells Fargo").where(:rank => 4).or.where(:name => "Bank of America").where(:rank => {"=" => 1, "!=" => 4}).to_query.should == {where:["or",["and", ["=", :name, "Wells Fargo"], ["=", :rank, 4]],["and", ["=", :name, "Bank of America"], ["=", :rank, 1], ["!=", :rank, 4]]]}
  end
  
  it "will implement to_query correctly for #order" do
    Bank.order(:rank).to_query.should == {order:[:rank, :asc]}
    
    Bank.order(:rank, :name => :desc).to_query.should       == {order:[[:rank, :asc], [:name, :desc]]}
    Bank.order(:rank).order(:name => :desc).to_query.should == {order:[[:rank, :asc], [:name, :desc]]}
    
    Bank.order(:rank, :id, :name => :desc).to_query.should       == {order:[[:rank, :asc], [:id, :asc], [:name, :desc]]}
    Bank.order(:rank, :id).order(:name => :desc).to_query.should == {order:[[:rank, :asc], [:id, :asc], [:name, :desc]]}
    Bank.order(:rank).order(:id, :name => :desc).to_query.should == {order:[[:rank, :asc], [:id, :asc], [:name, :desc]]}
    
    Bank.order(:rank, :id).order(:name, :created_at).to_query.should == {order:[[:rank, :asc], [:id, :asc], [:name, :asc], [:created_at, :asc]]}
  end
  
  it "will implement to_query correctly for #limit" do
    Bank.limit(1).to_query.should == {limit: 1}
  end
  
  it "will implement to_query correctly for #offset" do
    Bank.offset(1).to_query.should == {offset: 1}
  end
  
  it "will implement to_query correctly for #only" do
    Bank.only(:rank).to_query.should   == {only: :rank}
    
    Bank.only(:rank, :name).to_query.should          == {only: [:rank, :name]}
    Bank.only(:rank).only(:name).to_query.should     == {only: [:rank, :name]}
    
    Bank.only(:id).only(:rank, :name).to_query.should == {only: [:id, :rank, :name]}
    Bank.only(:id, :rank).only(:name).to_query.should == {only: [:id, :rank, :name]}
    
    Bank.only(:id, :rank).only(:name, :created_at).to_query.should == {only: [:id, :rank, :name, :created_at]}
  end
end