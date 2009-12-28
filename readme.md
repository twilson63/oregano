# Oregano

<small>Centralized Configuration Web Service</small>

## About

The name oregano is from the Greek word for "joy of the mountains".  The purpose of this application/service is to create a place where applications can store their configuration information without having to store it in their database or an app server file system.  The interface will be restful and will read and write json.  When registering to use the configuration you will be assigned a api key, this key will give you the ability to control your configuration data for a given namespace.  Only applications with this api key will be able to access your configuration information.  You will be required to provide a valid open id account to register namespaces.

## How it works

### Create Namespace and Get API Key

    # get '/register'
    
    # Fill out form with the following information
    
      # Namespace
    
      # OpenId
    
    # post '/register'
    
    # Once authorized the request will return an API Key for that namespace.
    

### Get and Set Configuration Settings

Now that you have your api key and namespace you will want to set some configuration information.  You simply post your configuration information to your namespace.  So if you namespace is "CustomerA" and you want to set the "database.uri" value.  You simply post the value to this uri:

    post '/customera/database/uri', "customera.database.com", :api_key => "1234"
    #
    
The if you want to retrieve the information back:

    get '/customera/database/uri', :api_key => "1234"
    #
  
You can also set multiple keys and values with one post:

    post '/customera/logserver', '{ "uri": "mylogserver.com", "api_key": "54321" }', :api_key => "1234"
    #

## Technology

