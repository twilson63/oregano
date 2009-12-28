require File.dirname(__FILE__) + '/spec_helper'

describe 'register' do
  include Rack::Test::Methods
  include Webrat::Matchers
  
  def app
    Oregano
  end
  
  it "should provide a form to register" do
    get '/login'
    #puts last_response.body
    last_response.should have_selector('form', :method => "post", :action => "/login")
    last_response.should have_selector('input', :type => "submit")
    last_response.should have_selector('input', :type => "text", :name => "openid_identifier")
    
  end
  
  # it "should allow for a post" do
  #   post '/login', :openid_identifier => "jackhq.myopenid.com"
  #   last_response.should have_selector('input', :type => "text", :name => "key")
  # end
    
end
