Gem::Specification.new do |s|
  s.name              = 'mongo_web'
  s.version           = '0.0.1'
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "A web interface for viewing MongoDB databases"
  s.homepage          = "http://github.com/ethangunderson/mongo_web"
  s.email             = "ethan@ethangunderson.com"
  s.authors           = [ "Ethan Gunderson" ]

  s.files             = %w( README.markdown  )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("spec/**/*")
  s.files            += Dir.glob("public/**/*")
  s.executables       = [ "mongo-web" ]

  s.add_dependency "mongo"
  s.add_dependency "vegas",   ">= 0.1.2"
  s.add_dependency "sinatra", ">= 0.9.2"
  s.add_dependency "haml"
  s.add_dependency "yajl-ruby"

  s.description = <<description
    Mongo_Web is a sinatra application for viewing MongoDB databases.
    
    If the code looks a lot like resque_web, that would be because I borrowed heavily from their implementation.
description
end