require 'vector'

class Node
	attr_reader :user, :edges
	attr_accessor :pos, :force, :vel, :color, :area
	def initialize(user=nil, x=0, y=0, a=300, c=rgb(0.0,0.0,1.0))
		@user = user
		@edges = {}
		self.pos = Vector.new x, y
		self.force = Vector.new 0, 0
		self.vel = Vector.new 0, 0
		self.area = a
		self.color = c
	end
	def self.from_twitter(user)
		Node.new user, 0, 0, user.updates, user.color
	end
	def info
		user.info
	end
	def mass
		area / 500.0
	end
	def <<(edge)
		v = (edge.u == self) ? edge.v : edge.u
		edges[v] = edge
	end
	def link_to(v)
		edges[v]
	end
	def radius
		Math.sqrt(area / Math::PI)
	end
	def ext_radius
		Math.sqrt(user.size / Math::PI)
	end
end
