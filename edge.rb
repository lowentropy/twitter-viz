class Edge
	attr_reader :u, :v
	attr_accessor :strength
	def initialize(u, v, strength)
		@u, @v = u, v
		self.strength = strength
	end
	def k(k0, norm)
		k0 * strength / norm
	end
end
