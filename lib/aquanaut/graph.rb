class Aquanaut::Graph
  include Enumerable

  def initialize
    @nodes = Hash.new
  end

  def add_node(node)
    @nodes[node.uri] ||= node
  end

  def add_edge(predecessor_uri, successor_uri)
    @nodes[predecessor_uri].add_edge(@nodes[successor_uri])
  end

  def [](uri)
    @nodes[uri]
  end

  def each
    @nodes.values.each do |node|
      yield node, node.adjacency_list
    end
  end

end
