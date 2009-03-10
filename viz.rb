#! /usr/local/bin/shoes

require 'graph'
require 'parse'

$width = 500
$height = 500

class TwitterViz < Shoes
	url '/', :index
	
	def index
		background white
		@graph = create_graph
		puts @graph
		@id = false
		keypress do |k|
			if k == 'r'
				background white
				@graph.layout! 0, 0, $width, $height
				draw_graph @graph
			elsif k == 'q'
				quit
			elsif k == 'n'
				@id = !@id
			end
		end
		motion do |x,y|
			if @id
				@graph.nodes.each do |node|
					r = node.radius
					d = (node.pos - Vector.new(x,y)).mag
					alert(node.info) if d < r
				end
			end
		end
	rescue
		handle($!)
	end

private

	def draw_graph(graph)
		graph.edges.each do |edge|
			draw_edge edge
		end
		graph.nodes.each do |node|
			draw_node node
		end
	end

	def draw_node(node)
		r = node.radius
		stroke black
		strokewidth 1
		color = node.color
		color = rgb(*color) if color.is_a? Array
		fill color
		x = node.pos.x - r
		y = node.pos.y - r
		oval x, y, r*2, r*2
		r = node.ext_radius
		return if r < node.radius
		x = node.pos.x - r
		y = node.pos.y - r
		nofill
		strokewidth 5
		oval x, y, r*2, r*2
	end

	def draw_edge(edge)
		x1, y1 = edge.u.pos.x, edge.u.pos.y
		x2, y2 = edge.v.pos.x, edge.v.pos.y
		stroke rgb(0.7, 0.7, 0.7)
		strokewidth edge.width
		line x1, y1, x2, y2
	end

	def create_graph
		# create_test_graph
		create_twitter_graph
	end

	def create_twitter_graph
		graph = Graph.new
		@users = parse_twitter("data.txt")
		graph.from_twitter @users, 'lowentropy', [$width/2,$height/2], 100
		graph
	end

	def create_test_graph
		graph = Graph.new
		until graph.nodes.size == 10
			node = Node.new
			node.area = rand(1000) + 200
			node.pos.rand! 0, 0, $width, $height
			graph << node
		end
		until graph.connected?
		#until graph.edges.size == 15
			u, v = graph.random_nodes(2)
			next if u.link_to v
			edge = graph.link! u, v
			edge.strength = rand(4) + 1
		end
		graph
	end

	def handle(err)
		puts err.message
		puts err.backtrace
	end

end

Shoes.app(
	:title => "Sources and Sinks in Twitter",
	:width => $width,
	:height => $height)
