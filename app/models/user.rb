class User < ActiveRecord::Base
  serialize :flights, Array
  serialize :holds, Array
end
