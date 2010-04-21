Mongo_Web
========

Mongo_Web is a sinatra application for viewing MongoDB databases.

If the code looks a lot like resque_web, that would be because I borrowed heavily from their implementation.

Installing
----------

gem install mongo_web

Usage
-----

Mongo_Web just uses Vegas to wrap a Sinatra application, so it's pretty simple to start up, just run

    $ mongo-web

You can also pass it a port to use

    $ mongo-web -p 6969

Limitations
-----------

It does not yet support GridFS