require 'graph'
require 'user'

def parse_twitter(filename)
	lines = File.read(filename).split /\n+/
	users = {}
	r1 = /^= ([a-zA-Z0-9_]+) (\d+) (\d+) (\d+) "([^"]*)" "([^"]*)"$/
	r2 = /^\+ ([a-zA-Z0-9_]+) (\d+)$/
	active = nil
	lines.each do |line|
		if (m = line.match(r1))
			user, friends, followers, updates, name, bio = m[1,6]
			users[user] = User.new(user, name, bio,
				friends.to_i, followers.to_i, updates.to_i)
			active = user
		elsif (m = line.match(r2))
			user, rank = m[1,2]
			users[active].add_friend user, rank
		else
			raise "bad line: #{line}"
		end
	end
	users
end
