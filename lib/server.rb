require 'sinatra/base'
require 'erb'
require 'mongo'

module MongoWeb
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :key => "value", views,  "#{dir}/server/views"
    set :public, "#{dir}/server/public"
    set :static, true
    
    get "/?" do
      redirect url(:overview)
    end

    %w( overview database collection document ).each do |page|
      get "/#{page}" do
        show page
      end
    end
    
    def show(page, layout = true)
      erb page.to_sym, {:layout => layout}
    end
  end
end