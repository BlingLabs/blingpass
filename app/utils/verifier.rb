class Verifier
	MAX_THRESHOLD = 0.5
	MIN_THRESHOLD = 0.3
	
	def self.verify(user, new_holds, new_flights)
		accuracy_count = 0
		for i in 0..(new_holds.length - 1)
			# Calculate deviation between new hold/flight time with avg hold/flight time
			deviation = Math::sqrt((new_holds[i] - user.holds[i])**2 + (new_flights[i] - user.flights[i])**2)

			if deviation > user.threshold
				# If the deviation is too high just bail out right away
				return false
			elsif deviation < MIN_THRESHOLD
				# If the deviation is really small, increase the accuracy count
				accuracy_count += 1
			end
				
			# Update averages and count so that we get more accurate over time
			user.holds[i] = (user.holds[i] * user.count + new_holds[i]) / (user.count + 1)
			user.flights[i] = (user.flights[i] * user.count + new_flights[i]) / (user.count + 1)
		end
		user.count += 1

		# Decrease threshold if the user is really accurate
		if accuracy_count == new_holds.length
			user.threshold -= 0.01 if user.threshold > MIN_THRESHOLD
		else
			user.threshold += 0.01 if user.threshold < MAX_THRESHOLD
		end

		return true
	end
end