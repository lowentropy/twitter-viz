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
	def from_twitter(users, root)
		return @names[root] if @names[root]
		user = users[root]
		raise "user '#{root}' not found!" unless user
		node = Node.from_twitter user
		@names[root] = node
		user.friends.each do |name,rank|
			fr = from_twitter(name)
			edge = link! node, fr
			edge.strength = 15.0 / (rank + 4)
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
		kr = 200.0
		ka = 1.0
		dt = 0.5
		damping = 0.9
		ke = nil
		# assign random positions, zero force
		nodes.each do |v|
			v.pos.rand! left, top, right, bottom
			v.vel.zero!
		end
		while ke.nil? or ke > 0.01
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
				v.pos.bound! left, top, right, bottom
				ke += v.mass * v.vel.mag**2
			end
			puts "KE = #{ke}"
			yield if block
		end
	rescue
		puts $!.message
		puts $!.backtrace
	end
end
