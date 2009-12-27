require File.dirname(__FILE__) + '/spec_helper'

describe 'register' do
  include Rack::Test::Methods
  include Webrat::Matchers
  
  def app
    Oregano
  end
  
  it "should provide a form to register" do
    get '/register'
    #puts last_response.body
    last_response.should have_selector('form', :method => "post", :action => "/register")
    last_response.should have_selector('input', :type => "submit")
    last_response.should have_selector('input', :type => "text", :name => "name")
    last_response.should have_selector('input', :type => "text", :name => "openid")
    
  end
  
  it "should allow for a post" do
    post '/register', :name => "cloudrx", :openid => "jackhq.myopenid.com"
    last_response.should have_selector('input', :type => "text", :name => "key")
  end
  
  it "should authenticate via openid"
  
  it "should not allow duplicate configuration names"
  
end
