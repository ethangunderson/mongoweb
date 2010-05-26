require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongo'

module MongoWeb
  class Server < Sinatra::Base
    DEFAULT_MONGO_HOST       = "localhost"
    DEFAULT_MONGO_PORT       = 27017
    MONGO_CONNECTION_SETUP   = lambda { |r| r.app.set_mongo_connection_from_args(r.args.first) }
    OPTIONS_SETUP            = proc do |runner, opts, app|
      opts.on('--mongo-username USERNAME', 'username for authentication against MongoDB database') do |mongo_username|
        app.set(:mongo_username, mongo_username)
      end

      opts.on('--mongo-password PASSWORD', 'password for authentication against MongoDB database') do |mongo_password|
        app.set(:mongo_password, mongo_password)
      end
      
      opts.banner = "Usage: #{$0 || app_name} [options] [database_connection_string]"
    end
    
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/server/views"
    set :static, true
    set :haml, { :format => :html5 }
    
    set :mongo, nil
    set :mongo_username, nil
    set :mongo_password, nil
    set :mongo_database_name, nil
    set :mongo_admin, false
    
    def self.set_mongo_connection_from_args(connection_string)
      host, port, database_name = connection_string.to_s.scan(/^(?:([^:]+?)(?::([^\/]+?))?\/)?(.+)$/).first
      effective_host = host || DEFAULT_MONGO_HOST
      effective_port = port || DEFAULT_MONGO_PORT
      
      connection = Mongo::Connection.new(effective_host, effective_port)
      set(:mongo, connection)
      
      if database_name && self.mongo_username && self.mongo_password
        database = mongo.db(database_name)
        database.authenticate(self.mongo_username, self.mongo_password)
        set(:mongo_database_name, database_name)
      else
        set(:mongo_admin, true)
      end
    end
    
    helpers do
      def mongo
        settings.mongo
      end
    
      def databases
        mongo.database_names
      end
      
      def collections(database_name)
        collections = mongo.db(database_name).collections
        unless settings.mongo_admin
          collections.reject { |collection| collection.name.match(/^system\./) }
        else
          collections
        end
      end
      
      def documents(database_name, collection_name)   
        mongo.db(database_name)[collection_name].find()
      end 
    end

    get '/' do
      if settings.mongo_admin
        redirect '/overview'
      else
        redirect "/database/#{settings.mongo_database_name}"
      end
    end

    get '/overview' do
      unless settings.mongo_admin
        redirect "/database/#{settings.mongo_database_name}"
      end
      
      haml :overview
    end
    
    get '/database/:name' do
      haml :database
    end
    
    get '/database/:name/:collection' do
      haml :collection
    end
    
    get '/stylesheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :stylesheet
    end
  end
end