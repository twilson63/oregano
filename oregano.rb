# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__), 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'sinatra/sequel'

class Oregano < Sinatra::Default

  set :database, ENV['DATABASE_URL'] || 'sqlite://oregano.db'

  migration "create the config table" do
    database.create_table :configurations do
      primary_key :id
      string :name
      string :owner
      string :access_key
      text :data

    end
  end
  
  class Configuration < Sequel::Model
    include Validatable
    validates_presence_of :name, :owner, :access_key
    
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
  

  get '/:name' do |name|
    # Find Namespace
    configuration = Configuration.find(:name => name)
    # Get Body and return it out
    configuration.body.to_json
  
  end

  post '/:name' do |name|
    x = request.body.read
    # Find Namespace
    configuration = Configuration.find(:name => name)
    # Set/Merge Hash to body and return it out
    configuration.body = configuration.body.merge(Crack::JSON.parse(x))
    configuration.save
    configuration.body.to_json
    
  end

end

