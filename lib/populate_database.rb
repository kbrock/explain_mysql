#!/usr/bin/env ruby

require "rubygems"
require "activerecord"
require 'ar-extensions'
require 'faker'
require 'lib/database'
require 'lib/person'
require 'lib/residence'
require 'lib/address'

require 'benchmark'
#modified 
#added 'if logger' to the end of:
#/opt/local/lib/ruby/gems/1.8/gems/activerecord-2.2.2/lib/active_record/base.rb#2793

##populate the database with data
class PopulateDatabase
  COMMIT_SIZE=200
  
  attr_accessor :people,:residences,:addresses
  
  def initialize
    @person_id=1
    @residence_id=1
    @addr_id=1
    
    @addresses=[]
    @residences=[]
    @people=[]
  end

  def populate(count,commit)
    groups=(count/commit).ceil
    #arrays to temporarily hold this data

    Benchmark.bm do |b|
#      b.report "load" do
      groups.times do
        b.report "create" do
          commit.times do
            create_person
          end
        end
        b.report "store" do
          store
        end
      end
#      end
    end
  end
  
  def create_person
    @people<<fake_person_data(@person_id)

    #0-4 addresses per person
    rand(5).times do
      @addresses << fake_address_data(@addr_id)
      @residences << [@residence_id,@person_id, @addr_id]

      @residence_id+=1
      @addr_id+=1
    end
    @person_id+=1
  end

  def store()
    store_people(@people)
    store_addresses(@addresses)
    store_residences(@residences)
    @people=[]
    @residences=[]
    @addresses=[]
  end
  
  PERSON_COLUMNS=[:id, :name, :parent_id, :manager_id]
  def fake_person_data(id)
    [id,Faker::Name.name, 0, 0]
  end
  
  def store_people(people)
    Person.import PERSON_COLUMNS, people
  end

  ADDRESS_COLUMNS=[:id, :street1, :street2, :street3, :city, :state, :zip ]
  def fake_address_data(id)
    [id, Faker::Address.street_address, "Apartment #{rand(200)+100}", "Floor #{rand(100)+1}",
      Faker::Address.city,"NY",Faker::Address.zip_code]
  end

  def store_addresses(addresses)
    Address.import(ADDRESS_COLUMNS, addresses)
  end
  
  RESIDENCE_COLUMNS=[:id,:person_id, :address_id]
  def store_residences(residences)
    Residence.import RESIDENCE_COLUMNS, residences
  end
end

if __FILE__ == $0
  count=begin $*[0].to_i rescue nil end
  count=2000 if (count.nil? || count == 0)

  commit=begin $*[0].to_i rescue nil end
  commit=500 if commit.nil?||commit==0
  commit=count if commit>count

  puts "truncating database"
  Database.new.connect.truncate
  puts "loading database with #{count} records in increments of #{commit}"
  PopulateDatabase.new.populate(count,commit)
  puts "done loading database..."
end
