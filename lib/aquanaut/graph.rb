require 'json'

# A graph representing the sitemap in terms of a data structure. A hash is
# used internally to make the nodes accessible through the URIs.
# 
class Aquanaut::Graph
  include Enumerable

  def initialize
    @nodes = Hash.new
  end

  # Use this method for making nodes available in the graph. New nodes are
  # only assigned once.
  #
  # @param [Node] node the node to add to the graph.
  # 
  def add_node(node)
    @nodes[node.uri] ||= node
  end

  # Use this method to easily add new edges without the need to pass actual
  # node objects. The method delegates the edge creation to the dedicated node
  # edge method.
  #
  # @param [URI] predecessor_uri source node for the edge
  # @param [URI] successor_uri target node for the edge
  #
  def add_edge(predecessor_uri, successor_uri)
    @nodes[predecessor_uri].add_edge(@nodes[successor_uri])
  end

  # Accessor method to retrieve nodes by their URI.
  #
  # @param [URI] uri the URI representing the node.
  #
  def [](uri)
    @nodes[uri]
  end

  # Accessor method to iterate the nodes and their adjacency list.
  #
  def each
    @nodes.values.each do |node|
      yield node, node.adjacency_list
    end
  end

  # Used for visualizing the graph on the front-end.
  #
  def to_json
    model = { 'nodes' => [], 'links' => [] }

    self.each do |node, adjacency|
      if node.instance_of?(Aquanaut::PageNode)
        group = 1
      else
        asset_groups = { 'image' => 2, 'stylesheet' => 3 }
        group = asset_groups[node.type]
      end

      model['nodes'] << { 'name' => node.uri, 'group' => group }
      source = @nodes.values.index(node)

      adjacency.each do |adjacency_node|
        target = @nodes.values.index(adjacency_node)
        model['links'] << { 'source' => source, 'target' => target }
      end
    end

    return model.to_json
  end

end
