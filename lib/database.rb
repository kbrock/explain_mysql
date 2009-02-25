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
      
    self
  end

  def create
    ActiveRecord::Schema.define do
      create_table :people do |t|
        t.integer :parent_id, :null => false, :default=> 0
        t.string :name,      :string, :null => false
        t.column :manager_id, :integer, :null => false, :default => 0
      end

      create_table :residences do |t|
        t.integer :person_id,:address_id, :null => false
      end

      create_table :addresses do |t|
        t.string :street1, :street2, :street3
        t.string :city, :state, :zip
      end
    end
    
    self
  end
  
  def createSimpleIndexes
    ActiveRecord::Schema.define do
      add_index :residences, :person_id
      add_index :residences, :address_id
    end  
    self  
  end
  
  def createComplexIndexes
    ActiveRecord::Schema.define do
      add_index :residences, [:person_id,:address_id], :name=>'index_residences_on_pa'
      add_index :residences, [:address_id,:person_id], :name=>'index_residences_on_ap'
    end
    self    
  end
  
  def dropIndexes
    ActiveRecord::Schema.define do
    begin
      remove_index :residences, :person_id
      remove_index :residences, :address_id
    rescue
    end
    begin
      #create unique index residences_pa on residences (person_id,address_id);
      remove_index :residences, :name => 'index_residences_on_pa'
      remove_index :residences, :name => 'index_residences_on_ap'
    rescue
    end
    end
  end
  
  def truncate
    ActiveRecord::Base.connection.execute('truncate table people')
    ActiveRecord::Base.connection.execute('truncate table addresses')
    ActiveRecord::Base.connection.execute('truncate table residences')
    
    self
  end
  
  def destroy
    ActiveRecord::Schema.define do
      drop_table :residences
      drop_table :addresses
      drop_table :people
    end
    self
  end
end

## running from the command line
if __FILE__ == $0
  d=Database.new
  d.connect

  case "#{$*}"
  when "destroy", "drop":
    d.destroy
  when "truncate":
    d.truncate
  when "reset":
    d.destroy.create
  when "simple":
    d.createSimpleIndexes
  when "complex":
    d.createComplexIndexes
  when "dropindex", "drop_index", "dropindexes", "drop_indexes":
    d.dropIndexes
  else
    d.create
  end
end