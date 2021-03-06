# Armada
Armada makes it simple and easy to combine ActiveModel and [FleetDB](http://fleetdb.org/) together.

## Installation
To install the gem:

    gem install armada
    
Make sure to download FleetDB and run it:

    wget http://fleetdb.s3.amazonaws.com/fleetdb-standalone.jar
    java -cp fleetdb-standalone.jar fleetdb.server -f swan.fdb
    
Documentation for the FleetDB server can be found at the [FleetDB website](http://fleetdb.org/docs/server.html).

## Usage
Begin by requiring Armada in your script or application.

    require "armada"
    
Be sure to set the timezone, as Armada currently makes use of it.

    Time.zone = "UTC"
    
To start Armada with the default settings, enter the following line:

    # This is the same as Armada.setup!(:address => "127.0.0.1", :port => 3400, :password => nil)
    Armada.setup!
    
To change the address, port, or password, `Armada.setup!` accepts these as keys in an option hash.

    Armada.setup!(:address => "4.8.15.16", :port => 2342, :password => "dharma")
    
This sets up the  basic fundamentals of Armada.  The following sections will detail how to fully utilize Armada's power.

### Models
Creating models in Armada is very easy.  The following code creates an Airplane model with a tail number attribute.

    class Airplane < Armada::Model
      add_columns :tail_number
    end
    
Armada models are fully compliant with ActiveModel.

    plane = Airplane.new(:tail_number => 815)

    plane.persisted? #=> false
    plane.destroy #=> false
    plane.valid? #=> true
    plane.errors #=> []

    plane.save #=> true
    plane.persisted? #=> true
    
    plane.destroy #=> true
    plane.persisted? #=> false

Armada models can also enjoy the added benefits of validation and automatic timestamps.

    class Airplane < Armada::Model
      add_columns :tail_number, :created_at, :updated_at
      validates :tail_number, :inclusion => {:in => [815, 316]}, :uniqueness => true
    end

    plane = Airplane.new(:tail_number => 816)
    plane.valid? #=> false

    plane.tail_number = 316
    plane.save #=> true
    plane.attributes #=> {"id"=>"b20e1cmt8mmjd7dzxu7wcjyg2", "tail_number"=>316,
                          "created_at"=>1272324264, "updated_at"=>1272324264}

All Armada models are given an id if none is specified during creation.  This is a requirement of FleetDB.  The default generation method is `generate_unique_id` in `Armada::Model`.  Note that Armada models can be treated very similarly to ActiveRecord models.

### Querying
All querying is handled through instances of `Armada::Relation`, which handle everything.  Read the FleetDB [query docs](http://fleetdb.org/docs/queries.html) for more detailed information.

    plane1 = Airplane.new(:tail_number => 815)
    plane2 = Airplane.new(:tail_number => 316)
    plane1.save
    plane2.save

    # Until specified, FleetDB has no order.
    Airplane.all #=> [plane1, plane2] | [plane2, plane1]
    
    Airplane.where(:tail_number => 815).all #=> [plane1]
    Airplane.where(:tail_number => 815).first #=> plane1
    
    # Using the FleetDB count command
    Airplane.where(:tail_number => 815).count #=> 1
    
    # Armada::Relation sets :order to :asc by default
    Airplane.order(:tail_number).all #=> [plane2, plane1]
    Airplane.order(:tail_number => :desc).all #=> [plane1, plane1]
    
    # Armada::Relation supports offset and limit just like SQL
    Airplane.order(:tail_number).limit(1).all #=> [plane2]
    Airplane.order(:tail_number).offset(1).all #=> [plane1]
    
    # The :only option allows choosing specific attributes
    Airplane.order(:tail_number).only(:tail_number).all #=> [316, 815]

## Credit
* [Mark McGranaghan](http://github.com/mmcgrana) - For developing FleetDB and providing a sample Ruby client.

## Copyright
Copyright © 2010 [Sam Aarons](http://github.com/saarons), released under the MIT license

