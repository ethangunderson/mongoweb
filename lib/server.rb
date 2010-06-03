require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongo'
require 'yajl'

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
    set :public, "public"
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
      
      def document(database_name, collection_name, id)
        mongo.db(database_name)[collection_name].find_one({ '_id' => BSON::ObjectID.from_string(id) })
      end
      
      def breadcrumbs
        bc = []
        
        if @database_name && @collection && @document
          bc << %Q{<a href="/overview">databases</a>}
          bc << %Q{<a href="/database/#{@database_name}">#{@database_name}</a>}
          bc << %Q{<a href="/database/#{@database_name}/#{@collection}">#{@collection}</a>}
          bc << @document_id
        elsif @database_name && @collection
          bc << %Q{<a href="/overview">databases</a>}
          bc << %Q{<a href="/database/#{@database_name}">#{@database_name}</a>}
          bc << @collection
        elsif @database_name
          bc << %Q{<a href="/overview">databases</a>}
          bc << @database_name
        end
        
        bc
      end
      
      def pretty_value(value)
        case value
        when String, Fixnum, BSON::ObjectID
          value.to_s
        when Hash, Array
          "<pre>#{Yajl::Encoder.encode(value, :pretty => true)}</pre>"
        else
          value.inspect
        end
      end
      
      def truncate(text, length = 30, omission = '...')
        return unless text
        return text if text.length < length
        
        out_text_length = (length / 2).floor
        text.slice(0, out_text_length) + omission + text.slice(-out_text_length, out_text_length)
      end
      
      def hash_without(hash, *keys)
        hash.inject({}) do |out, pair|
          key, value = pair
          next out if keys.include?(key)
          
          out[key] = value
          out
        end
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
    
    get '/database/:database_name' do |database_name|
      @database_name = database_name
      haml :database
    end
    
    get '/database/:database_name/:collection' do |database_name, collection|
      @database_name = database_name
      @collection = collection
      haml :collection
    end
    
    get '/database/:database_name/:collection/:id' do |database_name, collection, id|
      @database_name = database_name
      @collection = collection
      @document_id = id
      
      @document = document(database_name, collection, id)
      haml :document
    end
    
    get '/stylesheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :stylesheet
    end
  end
end