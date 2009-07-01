require 'node'
require 'edge'
require 'util'

# graph which assumes nodes and edges are weighted
class Graph

	include Layout
	attr_reader :nodes, :edges

	def initialize(nodes=[], edges=[])
		@nodes, @edges = nodes, edges
		@cells = {}
		@names = {}
	end

	# perform layout on nodes and collect edges
	def layout!
		@nodes = layout(@nodes)
		@edges = @nodes.map {|n| n.edges}.flatten.uniq
	end

	# append node to graph
	def <<(node)
		@nodes << node
	end

	# construct graph from a twitter network
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

	# select a number of random nodes from the graph
	def random_nodes(n)
		sel = []
		until sel.size == n
			node = nodes[rand(size)]
			next if sel.include? node
			sel << node
		end
		sel
	end

	# number of nodes in the graph
	def size
		nodes.size
	end

	# add and return a link between two nodes in the graph
	def link!(u, v)
		edge = Edge.new u, v, 1
		edges << edge
		u << edge
		v << edge
		edge
	end

	# convert to string
	def to_s
		nodes.each do |node|
			puts "AREA = #{node.area}, COLOR = #{node.color.inspect}"
		end
		edges.each do |edge|
			puts "STRENGTH = #{edge.strength}"
		end
	end
end
