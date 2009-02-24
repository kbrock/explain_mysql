class Address < ActiveRecord::Base
  has_many :people, :through=>:residence
end