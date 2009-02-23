#!/usr/bin/env ruby

require "rubygems"
require "activerecord"
require 'erb'

RAILS_ENV=ENV['RAILS_ENV']||'development'

#thanks http://pragdave.pragprog.com/pragdave/2006/07/migrations_outs.html
class Database
  def initialize
    @dbs = YAML::load(ERB.new(IO.read("database.yml")).result)
  end
  
  def connect
    # to slurp records into production db, change this line to production.
    curr_db = @dbs[RAILS_ENV]

    puts "curr_db: #{curr_db.inspect}"
    ActiveRecord::Base.establish_connection(:adapter => curr_db["adapter"],
    :host => curr_db["host"],
    :database => curr_db["database"],
    :username => curr_db["username"],
    :password => curr_db["password"])
  end

  def create
    ActiveRecord::Schema.define do
      create_table :person do |t|
        t.integer :parent_id
        t.string :name,      :string
        t.column :address_id,  :integer
        t.column :manager_id, :integer
      end
    #  create_table address do |t|
    #  end
    end
  end
  
  def destroy
    ActiveRecord::Schema.define do
      drop_table :person
    #  create_table address do |t|
    #  end
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
  else
    d.create
  end
end