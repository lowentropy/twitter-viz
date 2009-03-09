class Node
	attr_reader :user, :edges
	attr_accessor :pos, :force
	def initialize(user)
		@user = user
		@edges = {}
		self.pos = Vector.new 0, 0
		self.force = Vector.new 0, 0
	end
	def <<(edge)
		v = (edge.u == self) ? edge.v : edge.u
		edges[v] = edge
	end
	def link_to(v)
		edges[v]
	end
end
