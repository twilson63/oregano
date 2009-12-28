# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__), 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'sinatra/sequel'
require 'rack/openid'
require 'lib/access_key_generator'

class Oregano < Sinatra::Default
  include KeyGenerator
  
  set :database, ENV['DATABASE_URL'] || 'sqlite://oregano.db'
  set :root, File.dirname(__FILE__)

  # Session needs to be before Rack::OpenID
  use Rack::Session::Cookie
  use Rack::OpenID 
  
  enable :sessions
  
  migration "create the config table" do
    database.create_table :configurations do
      primary_key :id
      string :name
      string :openid_identifier
      string :access_key
      text :data

    end
  end
  
  class Configuration < Sequel::Model
    include Validatable
    validates_presence_of :name, :openid_identifier, :access_key
    # Need to verify name is unique!!!
    
    def body=(var)
      self.data = var.to_yaml
    end
    
    def body
      YAML::load(self.data) unless self.data.nil?
    end
    
       
  end
    
  get '/' do
    haml :index
  end
  
  get '/login' do
    haml :login
  end
  
  post '/login' do
    if resp = request.env["rack.openid.response"]
      if resp.status == :success
        session[:openid] = resp.display_identifier
        redirect "/"
      else
        "Error: #{resp.status}"
      end
    else
      headers 'WWW-Authenticate' => Rack::OpenID.build_header(
        :identifier => params["openid_identifier"]
      )
      throw :halt, [401, 'got openid?']
    end
    
  end
  
  get '/namespace' do
    haml :namespace
  end
  
  post '/namespace' do
    if session[:openid]    
      # authenticate openid
      # create config
      configuration = Configuration.create(params.merge(
        :access_key => generate_key,
        :openid_identifier => session[:openid]
      ))
      @access_key = configuration.access_key
      haml :confirmation
    else
      halt 401, "Must be logged in with Open ID!"
    end
  end

  get '/:name' do |name|
    if params[:api_key]
      # Find Namespace
      configuration = Configuration.find(:name => name)
      # authorize api
      halt 401, '{"error":"invalid api key"}' unless configuration.access_key == params[:api_key]
      # Get Body and return it out
      configuration.body.to_json
    end
  end

  post '/:name' do |name|
    x = request.body.read
    # Find Namespace
    configuration = Configuration.find(:name => name)
    # authorize api
    halt unless configuration.access_key == params[:api_key]
    # Set/Merge Hash to body and return it out
    configuration.body ||= {}
    configuration.body = configuration.body.merge(Crack::JSON.parse(x))
    configuration.save
    configuration.body.to_json
    
  end

end

