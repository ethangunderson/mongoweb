MongoWeb
========

MongoWeb is the stylish way of inspecting MongoDB databases.

Installing
----------

gem install mongo_web

Usage
-----

Starting MongoWeb is simple

    $ mongo-web

You can also pass it a specific port for the MongoWeb web server

    $ mongo-web -p 6969
    
You can connect to remote databases as well

    $ mongo-web [DATABASE CONNECTION STRING] --mongo-username USERNAME --mongo-password PASSWORD

Valid connection strings are

    foo                   # equivalent to localhost:27017/foo
    localhost/foo         # equivalent to localhost:27017/foo
    localhost:27018/foo

TODO
-----------

Support for:

* GridFS
* Editing Data

Screenshot
-----------------

![Screenshot](http://img.skitch.com/20100430-jdmu6nxijpbmq5ur72gwayghs7.jpg)