#!/usr/bin/env ruby

require "rubygems"
require "activerecord"
require 'erb'

RAILS_ENV=ENV['RAILS_ENV']||'development'

#thanks http://pragdave.pragprog.com/pragdave/2006/07/migrations_outs.html
class Database
  def initialize
    @dbs = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__),"../config/database.yml"))).result)
  end
  
  def connect
    # to slurp records into production db, change this line to production.
    curr_db = @dbs[RAILS_ENV]

    puts "curr_db: #{curr_db.inspect}"
    ActiveRecord::Base.establish_connection(
      :adapter => curr_db["adapter"],
      :host => curr_db["host"],
      :database => curr_db["database"],
      :username => curr_db["username"],
      :password => curr_db["password"])
  end

  def create
    ActiveRecord::Schema.define do
      create_table :people do |t|
        t.integer :parent_id, :nil => false, :default=> 0
        t.string :name,      :string, :nil => false
        t.column :manager_id, :integer, :nil => false, :default => 0
      end

      create_table :residences do |t|
        t.integer :person_id, :address_id, :nil => false
      end

      create_table :addresses do |t|
        t.string :street1, :street2, :street3
        t.string :city, :state, :zip
      end
    end
  end
  
  #not working
  def truncate
    ActiveRecord::Base.execute('use people ; truncate table people')
    ActiveRecord::Base.execute('use people ; truncate table addresses')
    ActiveRecord::Base.execute('use people ; truncate table residences')
  end
  
  def destroy
    ActiveRecord::Schema.define do
      drop_table :residences
      drop_table :addresses
      drop_table :people
    end
  end
end

## running from the command line
if __FILE__ == $0
  d=Database.new
  d.connect

  case "#{$*}"
  when "destroy", "drop":
    d.destroy
  when "truncate"
    d.truncate
  else
    d.create
  end
end