class User < ActiveRecord::Base
  serialize :flights, Array
  serialize :holds, Array

  before_create { self.count = 0 }
end
