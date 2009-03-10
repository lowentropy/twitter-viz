require 'hsv2rgb'

class User
	include Hsv2rgb
	attr_reader :user, :name, :bio, :friends, :followers, :updates
	def initialize(user, name, bio, friends, followers, updates)
		@user, @name, @bio, @friends, @followers, @updates = \
		user,  name,  bio,  friends,  followers,  updates
		@edges = {}
	end
	def add_friend(friend, rank)
		@edges[friend] = rank
	end
	def info
		str = user
		str << " (#{name})" if name
		str << "\n#{friends} friends,"
		str << " #{followers} followers"
		str << "\n#{bio}" if bio
		str
	end
	def each(&block)
		@edges.each &block
	end
	def green
		126.0
	end
	def blue
		243.0
	end
	def size
		friends + followers
	end
	def color
		a = (friends + followers).to_f
		b = (friends - followers).to_f
		h = (friends * blue + followers * green) / a
		s = b / a
		v = 0.8
		r,g,b,a = hsv(h,s,v)
		[0.1,g,b,a]
	end
	def rgb(r,g,b,a)
		[r,g,b,a]
	end
end
