# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__), 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'sinatra/sequel'
require 'lib/access_key_generator'

class Oregano < Sinatra::Default
  include KeyGenerator
  
  set :database, ENV['DATABASE_URL'] || 'sqlite://oregano.db'
  set :root, File.dirname(__FILE__)

  migration "create the config table" do
    database.create_table :configurations do
      primary_key :id
      string :name
      string :openid
      string :access_key
      text :data

    end
  end
  
  class Configuration < Sequel::Model
    include Validatable
    validates_presence_of :name, :openid, :access_key
    # Need to verify name is unique!!!
    
    def body=(var)
      self.data = var.to_yaml
    end
    
    def body
      YAML::load(self.data) unless self.data.nil?
    end
    
       
  end
    
  get '/' do
    "Welcome to Oregano"
  end
  
  get '/register' do
    haml :register
  end
  
  post '/register' do
    # authenticate openid
    # create config
    configuration = Configuration.create(params.merge(:access_key => generate_key))
    @access_key = configuration.access_key
    haml :confirmation
  end

  get '/:name' do |name|
    # Find Namespace
    configuration = Configuration.find(:name => name)
    # authorize api
    halt 401, '{"error":"invalid api key"}' unless configuration.access_key == params[:api_key]
    # Get Body and return it out
    configuration.body.to_json
  
  end

  post '/:name' do |name|
    x = request.body.read
    # Find Namespace
    configuration = Configuration.find(:name => name)
    # authorize api
    halt unless configuration.access_key == params[:api_key]
    # Set/Merge Hash to body and return it out
    configuration.body = configuration.body.merge(Crack::JSON.parse(x))
    configuration.save
    configuration.body.to_json
    
  end

end

