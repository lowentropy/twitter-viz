require 'vector'

class Node
	attr_reader :user, :edges
	attr_accessor :pos, :force, :color, :area
	def initialize(user=nil, x=0, y=0, a=300, c=rgb(0.0,0.0,1.0))
		@user = user
		@edges = {}
		self.pos = Vector.new x, y
		self.force = Vector.new 0, 0
		self.area = a
		self.color = c
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
end
