require File.dirname(__FILE__) + '/../spec_helper'

describe Oregano::Configuration do

  before(:each) do
    # Clean Table
    Oregano::Configuration.each { |c| c.destroy }
    
    @config = Oregano::Configuration.new(  :name => "widget", 
                          :openid_identifier => "tom@test.com", 
                          :access_key => "1234")
    
  end
  
  it "should be valid" do
    @config.should be_valid
  end
  
  it "should read and write hash for body" do
    @config.body = {:hello => "world"}
    @config.body[:hello] == "world"
  end
  
end
  