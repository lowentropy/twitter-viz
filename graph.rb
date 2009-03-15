require 'node'
require 'edge'
require 'util'

class Graph
	attr_reader :nodes, :edges
	def initialize(nodes=[], edges=[])
		@nodes, @edges = nodes, edges
		@cells = {}
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
		node.pos.set_to pos
		@names[root] = node
		self << node
		user.each do |name,rank|
			x = pos[0] + rand(rng)
			y = pos[1] + rand(rng)
			f = from_twitter(users, name, [x,y], rng/2)
			edge = link! node, f
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

	def to_s
		nodes.each do |node|
			puts "AREA = #{node.area}, COLOR = #{node.color.inspect}"
		end
		edges.each do |edge|
			puts "STRENGTH = #{edge.strength}"
		end
	end
end
