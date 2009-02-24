class Person < ActiveRecord::Base
  has_many :addresses, :through => :residence
end