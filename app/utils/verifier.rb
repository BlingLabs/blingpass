class Verifier
  MAX_THRESHOLD = 160
  MIN_THRESHOLD = 100
  FAST_PASSWORD_THRESHOLD = 90
  MAX_FLIGHT_PERCENTAGE_DIFFERENCE_THRESHOLD = 0.75
  MAX_HOLD_PERCENTAGE_DIFFERENCE_THRESHOLD = 0.45

  def self.verify(user, new_holds, new_flights)
    pp "new flights " + new_flights.to_s
    pp "avg new flight " + (new_flights.inject(:+)/(new_flights.length-1)).to_s
    pp "user flights " + user.flights.to_s

    pp "new holds " + new_holds.to_s
    pp "avg new hold " + (new_holds.inject(:+)/(new_holds.length)).to_s
    pp "user holds " + user.holds.to_s

    if new_flights.inject(:+)/(new_flights.length-1) < FAST_PASSWORD_THRESHOLD
      self.verify_fast(user, new_holds, new_flights)
    else
      self.verify_slow(user, new_holds, new_flights)
    end
  end

  def self.verify_fast(user, new_holds, new_flights)
    percentage_differences = Array.new(new_flights.length)

    pp "flight percentage differences"
    for i in 1..(new_flights.length - 1)
      percentage_differences[i] = ((new_flights[i].to_f - user.flights[i].to_f)/user.flights[i].to_f).abs
      pp percentage_differences[i]
      return false if percentage_differences[i] > MAX_FLIGHT_PERCENTAGE_DIFFERENCE_THRESHOLD
    end

    pp "hold percentage differences"
    for i in 0..(new_flights.length - 1)
      percentage_differences[i] = ((new_holds[i].to_f - user.holds[i].to_f)/user.holds[i].to_f).abs
      pp percentage_differences[i]
      return false if percentage_differences[i] > MAX_HOLD_PERCENTAGE_DIFFERENCE_THRESHOLD
    end

    self.update_average(user, new_holds, new_flights)

    return true
  end

  def self.verify_slow(user, new_holds, new_flights)
    accuracy_count = 0
    for i in 0..(new_holds.length - 1)
      # Calculate deviation between new hold/flight time with avg hold/flight time
      deviation = Math::sqrt((new_holds[i].to_i - user.holds[i].to_i)**2 + (new_flights[i].to_i - user.flights[i].to_i)**2)

      pp "threshold " + user.threshold.to_s
      pp "deviation " + deviation.to_s

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

    pp "accuracy count " + accuracy_count.to_s
    pp "length " + new_holds.length.to_s
    # Decrease threshold if the user is really accurate
    if accuracy_count == new_holds.length
      pp "decreasing user threshold"
      user.threshold -= 10 if user.threshold > MIN_THRESHOLD + 10
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
