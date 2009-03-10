include Math

class Vector
	attr_accessor :x, :y
	def initialize(x, y)
		self.x, self.y = x, y
	end
	def mag
		dot = (x*x + y*y).to_f
		dot.nan? ? 0.0 : sqrt(dot)
	end
	def dir
		m = mag
		if m < 0.00001
			self
		else
			self / mag
		end
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
	def fix_nan!
		self.x = 0.0 if self.x.nan?
		self.y = 0.0 if self.y.nan?
	end
	def bound!(x1, y1, x2, y2)
		self.fix_nan!
		self.x = [x1, [x2, x].min].max
		self.y = [y1, [y2, y].min].max
	end
end
