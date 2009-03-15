include Math

class Vector
	attr_accessor :x, :y
	def initialize(x, y)
		self.x, self.y = x, y
	end
	def set_to(array)
		self.x, self.y = array
	end
	def decompose(k=1)
		m = fix! k
		[m, dir(m)]
	end
	def fix!(k=1)
		if (m = mag) < 0.000001
			self.x = 0.001 * k * (rand * 1.4 - 0.7)
			self.y = 0.001 * k * (rand * 1.4 - 0.7)
			m = mag
		end
		m
	end
	def mag
		sqrt(x*x + y*y)
	end
	def dir(m=mag)
		if m < 0.00001
			self
		else
			self / m
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
	def bound!(x1, y1, x2, y2)
		self.fix_nan!
		self.x = [x1, [x2, x].min].max
		self.y = [y1, [y2, y].min].max
	end
	def transform!(r1, r2)
		self.x = transform(x, r1[0], r1[2], r2[0], r2[2])
		self.y = transform(y, r1[1], r1[3], r2[1], r2[3])
	end
private
	def transform(x, a, b, c, d)
		(x - a) * (d - c) / (b - a) + c
	end
end
