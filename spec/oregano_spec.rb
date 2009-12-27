require File.dirname(__FILE__) + '/spec_helper'

describe 'namespace test' do
  include Rack::Test::Methods
  
  def app
    Oregano
  end
  
  before(:each) do
    # Clean Table
    Oregano::Configuration.each { |c| c.destroy }

    # Create Widget Config
    Oregano::Configuration.create do |c|
      c.name = "widget"
      c.owner = "tom@jackhq.com"
      c.access_key = "1234"
      c.body = { :test => true }
    end
    
  end
  
  it 'should return ok' do
    get '/' 
    last_response.should be_ok
  end
  
  it 'should not return widget without api key' do
    get '/widget'
    last_response.status.should == 401
    Crack::JSON.parse(last_response.body)["error"].should == "invalid api key"
  end
  
  
  it 'should return widget config' do
            
    get '/widget?api_key=1234'
    
    #last_response.body.should == "{\"test\":true}"
    Crack::JSON.parse(last_response.body)["test"].should be_true
  end
  
  it 'should set config param' do
    
    post '/widget?api_key=1234', '{"uri": "myuri.com"}'
    Crack::JSON.parse(last_response.body)["test"].should be_true
    Crack::JSON.parse(last_response.body)["uri"].should == "myuri.com"
  end
  
  it 'should set config params in nested levels' do
    post '/widget?api_key=1234', '{"database": { "uri": "uri.com", "user": "admin"}}'
    Crack::JSON.parse(last_response.body)["test"].should be_true
    Crack::JSON.parse(last_response.body)["database"]["uri"].should == "uri.com"
  end
end
