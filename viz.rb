#! /usr/local/bin/shoes

require 'graph'

$width = 500
$height = 500

class TwitterViz < Shoes
	url '/', :index
	
	def index
		background white
		@graph = create_graph
		draw_graph @graph
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
		fill node.color
		x = node.pos.x - r/2
		y = node.pos.y - r/2
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
		node = Node.new
		node.pos.x = $width / 2
		node.pos.y = $height / 2
		graph = Graph.new
		graph << node
		graph
	end

	def handle(err)
		puts err
		puts err.backtrace
	end

end

Shoes.app(
	:title => "Sources and Sinks in Twitter",
	:width => $width,
	:height => $height)
