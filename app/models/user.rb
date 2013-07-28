class User < ActiveRecord::Base
  has_secure_password validations: false

  serialize :flights, Array
  serialize :holds, Array

  before_create do
    self.count = 0
    self.threshold = Verifier::MAX_THRESHOLD  
  end

end
