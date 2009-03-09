include Math

def spring_layout(nodes, edges, width, height, iter=50, falloff=0.1, temp=nil)
	# set up constants
	temp ||= sqrt(width * height) / 2
	k0 = sqrt(width * height / nodes.size.to_f)
	s_norm = edges.map {|e| e.strength}.sum
	# assign random positions, zero force
	nodes.each do |v|
		v.pos.rand! 0, 0, width, height
		v.force.zero!
	end
	iter.times do
		# calculate repulsive forces
		nodes.each do |v|
			nodes.each do |u|
				next if u == v
				d = v.pos - u.pos
				k = (e = v.edge_to(u)) ? e.k(k0, s) : k0
				v.force -= d.dir * k**2 / d.mag
			end
		end
		# calculate attractive forces
		edges.each do |e|
			d = e.v.pos - e.u.pos
			k = e.k(k0, s)
			f = d.dir * d.mag**2 / k
			e.u.force += f
			e.v.force -= f
		end
		# update positions
		nodes.each do |v|
			v.pos += v.force.dir * [v.force.mag, temp].min
			v.pos.bound! 0, 0, width, height
		end
		# cool system
		temp *= (1 - falloff)
	end
end
