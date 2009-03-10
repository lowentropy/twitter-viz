# returns a shoes color
module Hsv2rgb
	def hsv(h, s, v, a=1.0)
		h, s, v = h.to_f, s.to_f, v.to_f
		return rgb(v,v,v,1.0) if s == 0
		h *= 6
		i = h.floor
		v1 = v * (1 - s)
		v2 = v * (1 - s * (h - i))
		v3 = v * (1 - s * (1 - h + i))
		case i
			when 0 then rgb(v, v3, v1, a)
			when 1 then rgb(v2, v, v1, a)
			when 2 then rgb(v1, v, v3, a)
			when 3 then rgb(v1, v2, v, a)
			when 4 then rgb(v3, v1, v, a)
			       else rgb(v, v1, v2, a)
		end
	end
end
