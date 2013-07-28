class Verifier
  MAX_THRESHOLD = 200
  MIN_THRESHOLD = 50

  def self.verify(user, new_holds, new_flights)
    accuracy_count = 0
    for i in 0..(new_holds.length - 1)
      # Calculate deviation between new hold/flight time with avg hold/flight time
      deviation = Math::sqrt((new_holds[i].to_i - user.holds[i].to_i)**2 + (new_flights[i].to_i - user.flights[i].to_i)**2)
      
      pp "deviation is " + deviation.to_s
      ap user

      if deviation > user.threshold
        # If the deviation is too high just bail out right away
        return false
      elsif deviation < MIN_THRESHOLD
        # If the deviation is really small, increase the accuracy count
        accuracy_count += 1
      end
    end

    self.update_average(user, new_holds, new_flights)
    user.count += 1

    # Decrease threshold if the user is really accurate
    if accuracy_count == new_holds.length
      user.threshold -= 10 if user.threshold > MIN_THRESHOLD
    else
      user.threshold += 10 if user.threshold < MAX_THRESHOLD
    end

    return true
  end

  def self.update_average(user, new_holds, new_flights)
    for i in 0..(new_holds.length - 1)        
      # Update averages and count so that we get more accurate over time
      user.holds[i] = (user.holds[i].to_i * user.count + new_holds[i].to_i) / (user.count + 1)
      user.flights[i] = (user.flights[i].to_i * user.count + new_flights[i].to_i) / (user.count + 1)
    end
  end
end
