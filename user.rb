require 'hsv2rgb'

class User
	include Hsv2rgb
	attr_reader :user, :name, :bio, :friends, :followers, :updates
	def initialize(user, name, bio, friends, followers, updates)
		@user, @name, @bio, @friends, @followers, @updates = \
		user,  name,  bio,  friends,  followers,  updates
		@friends = {}
	end
	def <<(friend, rank)
		@friends[friend] = rank
	end
	def each(&block)
		@friends.each &block
	end
	def color
		a = (friends + followers).to_f
		b = (friends - followers).to_f
		h = (friends * blue + followers * green) / a
		s = b / a
		v = 0.8
		hsv(h,s,v)
	end
	def rgb(r,g,b)
		[r,g,b]
	end
end
