require 'node'
require 'edge'
require 'util'

class Graph
	attr_reader :nodes, :edges
	def initialize(nodes=[], edges=[])
		@nodes, @edges = nodes, edges
		@names = {}
	end
	def <<(node_or_edge)
		if node_or_edge.is_a? Node
			@nodes << node_or_edge
		else
			@edges << node_or_edge
		end
	end
	def from_twitter(users, root, pos, rng)
		return @names[root] if @names[root]
		user = users[root]
		raise "user '#{root}' not found!" unless user
		node = Node.from_twitter user
		node.pos.x = pos[0]
		node.pos.y = pos[1]
		@names[root] = node
		self << node
		user.each do |name,rank|
			x = pos[0] + rand(rng)
			y = pos[1] = rand(rng)
			fr = from_twitter(users, name, [x,y], rng/2)
			edge = link! node, fr
			edge.strength = 15.0 / (rank.to_i + 4)
		end
		node
	end
	def random_nodes(n)
		sel = []
		until sel.size == n
			node = nodes[rand(size)]
			next if sel.include? node
			sel << node
		end
		sel
	end
	def size
		nodes.size
	end
	def connected?
		nodes.all? {|n| n.edges.size > 0}
	end
	def link!(u, v)
		edge = Edge.new u, v, 1
		edges << edge
		u << edge
		v << edge
		edge
	end
	def layout!(left, top, right, bottom, iter=200, falloff=0.01, temp=nil, &block)
		# set up constants
		width, height = right - left, bottom - top
		l0 = 2.0 * sqrt(width * height / nodes.size.to_f)
		kr = 100.0
		ka = 2.0
		dt = 0.1
		damping = 0.3
		ke = nil
		iter = 0
		# assign random positions, zero force
		nodes.each do |v|
			v.pos.rand! left, top, right, bottom
			v.vel.zero!
		end
		while (ke.nil? or ke > 0.01) and iter < 200
			iter += 1
			# calculate repulsive forces
			nodes.each do |v|
				v.force.zero!
				nodes.each do |u|
					next if u == v
					d = v.pos - u.pos
					f = d.dir * kr / (d.mag**2)
					v.force += f
				end
			end
			# calculate attractive forces
			nodes.each do |v|
				nodes.each do |u|
					next if v == u
					if (e = v.link_to u)
						l = l0 / e.strength
					else
						l = l0
					end
					d = v.pos - u.pos
					f = d.dir * ka * (d.mag - l)
					v.force -= f
				end
			end
			# update positions
			ke = 0.0
			nodes.each do |v|
				v.vel += v.force * dt
				v.vel *= damping
				v.pos += v.vel * dt
				#v.pos.bound! left, top, right, bottom
				ke += v.mass * v.vel.mag**2
			end
			puts "#{iter}: KE = #{ke}"
			yield if block
		end
		# normalize
		x0, x1, y0, y1 = right, left, bottom, top
		nodes.each do |v|
			x0 = v.pos.x if v.pos.x < x0
			x1 = v.pos.x if v.pos.x > x1
			y0 = v.pos.y if v.pos.y < y0
			y1 = v.pos.y if v.pos.y > y1
		end
		puts "#{x0}, #{y0} -> #{x1}, #{y1}"
		nodes.each do |v|
			m = 10
			v.pos.transform!([x0, y0, x1, y1], [left+m, top+m, right-m, bottom-m])
		end
	rescue
		puts $!.message
		puts $!.backtrace
	end
	def to_s
		nodes.each do |node|
			puts "AREA = #{node.area}, COLOR = #{node.color.inspect}"
		end
		edges.each do |edge|
			puts "STRENGTH = #{edge.strength}"
		end
	end
end
