require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongo'

module MongoWeb
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/server/views"
    set :static, true
    set :haml, { :format => :html5 }
    
    helpers do
      def mongo
        @mongo ||= Mongo::Connection.new
      end
    
      def databases
        mongo.database_names
      end
      
      def collections(database_name)
        mongo.db(database_name).collections
      end
      
      def documents(database_name, collection_name)   
        mongo.db(database_name)[collection_name].find()
      end 
    end

    get '/' do
      redirect '/overview'
    end

    get '/overview' do
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