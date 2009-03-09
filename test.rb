#! /usr/local/bin/shoes

class TestApp < Shoes
	include Math
	url '/', :index
	def index
		line_arrows 10, 10, 40, 40, 5, true, true
		nostroke; fill red
		oval 9, 9, 3
		oval 39, 39, 3
	end
	def line_arrows(x1, y1, x2, y2, size, from_arrow, to_arrow)
		angle = -atan2(y2 - y1, x2 - x1) * 180 / PI
		line x1, x2, y1, y2
		rotate angle
		arrow x2, y2, size if to_arrow
		rotate 180
		arrow x1, y1, size if from_arrow
		rotate 180 - angle
	rescue
		puts $!.message
	end
end

Shoes.app :title => 'Sources and Sinks'
