require File.dirname(__FILE__) + '/spec_helper'

describe 'namespace' do
  include Rack::Test::Methods
  include Webrat::Matchers
  
  def app
    Oregano
  end
  
  it "should provide a form to create namespace" do
    get '/namespace'
    #puts last_response.body
    last_response.should have_selector('form', :method => "post", :action => "/namespace")
    last_response.should have_selector('input', :type => "submit")
    last_response.should have_selector('input', :type => "text", :name => "name")
    
  end
  
  it "should allow for a post" do
    #@app.session = { :openid => "jackhq.myopenid.com"}
    #set_cookie("rack.session={'openid' => 'jackhq.myopenid.com'}")
    
    post '/namespace', :name => "cloudrx"
    puts last_request.cookies.inspect
    last_response.should have_selector('input', :type => "text", :name => "key")
  end
    
end
