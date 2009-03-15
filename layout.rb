module MultiLevelLayout

	def layout(nodes)
		distribute_edge_weights(nodes)
		force_layout(nodes)
	end

private

	def force_layout(nodes)
		# base case can be set arbitrarily
		if nodes.size == 2
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
			return nodes
		end
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

	def fr(x, w)
		if x <= @r
			-@force * w * @k**2 / x
		else
			0.0
		end
	end

	def fa(x)
		x**2 / @k
	end

	def find_cell(pos)
		x = pos.x / @r
		y = pos.y / @r
		index = [x.to_i, y.to_i]
		@cells[index] ||= []
	end

	def delete_cells!
		@cells = {}
	end

	def parent_layout(nodes)
		shrunk = shrink nodes
		layout = force_layout shrunk
		expand layout
	end

	def shrink(nodes)
		shrunk = nodes[0..-1]
	end

	def expand(nodes)
	end

	def distribute_edge_weights(nodes)
		nodes.each do |v|
			v.weight = 0
			v.edges.each do |edge|
				v.weight += edge.weight
			end
		end
	end
end
