class Verifier
  MAX_FLIGHT_PERCENTAGE_DIFFERENCE_THRESHOLD = 1.20
  MAX_HOLD_PERCENTAGE_DIFFERENCE_THRESHOLD = 0.65
  #MAX_FLIGHT_PERCENTAGE_DIFFERENCE_THRESHOLD = 1.40
  #MAX_HOLD_PERCENTAGE_DIFFERENCE_THRESHOLD = 0.80
  MAX_THRESHOLD_MS = 160
  MIN_THRESHOLD_MS = 90
  THRESHOLD_INCREMENT_MS = 10

  # Verify user's identity using percentage difference and absolute difference of hold/flight times
  def self.verify(user, new_holds, new_flights)
    pp "new flights " + new_flights.to_s
    pp "avg new flight " + (new_flights.inject(:+)/(new_flights.length-1)).to_s unless new_flights.blank?
    pp "user flights " + user.flights.to_s

    pp "new holds " + new_holds.to_s
    pp "avg new hold " + (new_holds.inject(:+)/(new_holds.length)).to_s unless new_holds.blank?
    pp "user holds " + user.holds.to_s

    pass = self.verify_percentage_difference(user, new_holds, new_flights) and self.verify_absolute_difference(user, new_holds, new_flights)
    user.count += 1
    return pass
  end

  # Verify percentage difference of hold and flight times.
  def self.verify_percentage_difference(user, new_holds, new_flights)
    percentage_differences = Array.new(new_flights.length)

    pp "flight percentage differences"
    for i in 1..(new_flights.length - 1)
      percentage_differences[i] = ((new_flights[i].to_f - user.flights[i])/user.flights[i]).abs
      pp percentage_differences[i]
      return false if percentage_differences[i] > MAX_FLIGHT_PERCENTAGE_DIFFERENCE_THRESHOLD
    end

    pp "hold percentage differences"
    for i in 0..(new_flights.length - 1)
      percentage_differences[i] = ((new_holds[i].to_f - user.holds[i])/user.holds[i]).abs
      pp percentage_differences[i]
      return false if percentage_differences[i] > MAX_HOLD_PERCENTAGE_DIFFERENCE_THRESHOLD
    end

    self.update_average(user, new_holds, new_flights)

    return true
  end

  # Calculate the absolute difference between new hold/flight times and the user's avg hold/flight times.
  def self.verify_absolute_difference(user, new_holds, new_flights)
    pp "absolute difference"

    accuracy_count = 0
    pp "threshold " + user.threshold.to_s
    for i in 0..(new_holds.length - 1)
      # Calculate absolute difference between new hold/flight time with avg hold/flight time
      absolute_difference = Math::sqrt((new_holds[i].to_i - user.holds[i])**2 + (new_flights[i].to_i - user.flights[i])**2)
      pp "absolute difference " + absolute_difference.to_s

      if absolute_difference > user.threshold
        # If the absolute_difference is too high just bail out right away
        return false
      elsif absolute_difference < MIN_THRESHOLD_MS
        # If the absolute_difference is really small, increase the accuracy count
        accuracy_count += 1
      end
    end

    self.update_average(user, new_holds, new_flights)

    # Decrease threshold if the user is really accurate
    if accuracy_count == new_holds.length
      pp "decreasing user threshold"
      user.threshold -= THRESHOLD_INCREMENT_MS if user.threshold > MIN_THRESHOLD_MS + THRESHOLD_INCREMENT_MS
    else
      pp "increasing user threshold"
      user.threshold += THRESHOLD_INCREMENT_MS if user.threshold < MAX_THRESHOLD_MS
    end

    return true
  end

  # Update averages and count so that we get more accurate over time
  # Should always increment count after calling this function
  def self.update_average(user, new_holds, new_flights)
    for i in 0..(new_holds.length - 1)        
      user.holds[i] = (user.holds[i].to_i * user.count + new_holds[i].to_i) / (user.count + 1)
      user.flights[i] = (user.flights[i].to_i * user.count + new_flights[i].to_i) / (user.count + 1)
    end
  end
end
