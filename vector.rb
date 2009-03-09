include Math

class Vector
	attr_accessor :x, :y
	def initialize(x, y)
		self.x, self.y = x, y
	end
	def mag
		sqrt(x*x + y*y)
	end
	def dir
		self / mag
	end
	def +(v)
		Vector.new x+v.x, y+v.y
	end
	def -(v)
		Vector.new x-v.x, y-v.y
	end
	def *(s)
		Vector.new x*s, y*s
	end
	def /(s)
		self * (1.0/s)
	end
	def rand!(x1, y1, x2, y2)
		self.x = rand * (x2 - x1) + x1
		self.y = rand * (y2 - y1) + y1
	end
	def zero!
		self.x, self.y = 0, 0
	end
	def bound!(x1, y1, x2, y2)
		self.x = [x1, [x2, x].min].max
		self.y = [y1, [y2, y].min].max
	end
end
