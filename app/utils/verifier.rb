class Verifier
	THRESHOLD = 0.1
	def self.verify(user, hold, flight)
		for i in 0..(hold.length - 1)
			# Calculate deviation between new hold/flight time with avg hold/flight time
			deviation = Math::sqrt((hold[i] - user.avg_hold[i])**2 + (flight[i] - user.avg_flight[i])**2)

			# If the deviation is too high just bail out right away
			if deviation > THRESHOLD
				return false
			end

			# Update averages and count so that we get more accurate over time
			user.avg_hold[i] = (user.avg_hold[i] * user.count + hold[i]) / (user.count + 1)
			user.avg_flight[i] = (user.avg_flight[i] * user.count + flight[i]) / (user.count + 1)
			user.count += 1
		end
		return true
	end
end