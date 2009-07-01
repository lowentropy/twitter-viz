# see C Walshaw, "A Multilevel Algorithm for Force-Directed Graph-Drawing"
module MultiLevelLayout

	# top-level layout
	def layout(nodes)
		if nodes.size == 2
			root_layout(nodes)
		else
			force_layout(nodes)
		end
	end

private

	# base case can be set arbitrarily
	def root_layout(nodes)
		# set up fixed constants
		@damp = 0.9
		@tol = 0.01
		@force = 0.2
		@grow = sqrt(7.0/4.0)
		# set up initial constants
		@k = 100
		@l = 0
		# position two nodes
		nodes[0].pos.set_to  0, 0
		nodes[1].pos.set_to @k, 0
		nodes
	end

	# FDP case; coulomb forces and springs, yay!
	def force_layout(nodes)
		# first, obtain layout of parent graph
		nodes = parent_layout(nodes)
		# update constants
		@l = @l + 1
		@k = @k * @grow
		@r = 2 * (@l + 1) * @k
		@t = @k
		# loop until convergence
		converged = false
		until converged
			converged = true
			# divide nodes into cells
			delete_cells!
			nodes.each do |v|
				v.cell = find_cell(v.pos)
				v.cell << v
			end
			# calculate forces on each node
			nodes.each do |v|
				# repulsive force within cell
				v.cell.each do |u|
					next if u == v
					dir, mag = (u - v).decompose(@k)
					v.disp = dir * fr(mag, u.weight)
				end
				# attractive force on edges
				v.neighbors.each do |u|
					dir, mag = (u - v).decompose(@k)
					v.disp += dir * fa(mag)
				end
				# move the node
				dir, mag = v.disp.decompose(@k)
				v.pos += dir * [@t, mag].min
				# check for nonconvergence
				converged = false if mag > @k * @tol
			end
			# cool the system
			@t = @t * @damp
		end
	end

	# repulsive force, from cell members only
	def fr(x, w)
		if x <= @r
			-@force * w * @k**2 / x
		else
			0.0
		end
	end

	# attractive force, for linked nodes only
	def fa(x)
		x**2 / @k
	end

	# divide area based on grid
	def find_cell(pos)
		x = pos.x / @r
		y = pos.y / @r
		index = [x.to_i, y.to_i]
		@cells[index] ||= []
	end

	# reset cells
	def delete_cells!
		@cells = {}
	end

	# lay out a coarser graph, then expand it
	def parent_layout(nodes)
		expand(layout(shrink(nodes)))
	end

	# shrink graph by combining vertex pairs
	def shrink(nodes)
		nodes = nodes[0..-1]
		while nodes.any?
			u = nodes.delete_at rand(nodes.size)
			v = u.neighbors.sort_by {|n| n.weight}.first
			nodes.delete v
			# TODO: have to track new edges and do actual merge
		end
		# TODO
	end

	# expand graph by adding vertices at location of group
	def expand(nodes)
		# TODO
	end

end
