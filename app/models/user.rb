class User < ActiveRecord::Base
  serialize :flights, Array
  serialize :holds, Array

  before_create do
    self.count = 0
    self.threshold = Verifier::MAX_THRESHOLD  
  end

end
