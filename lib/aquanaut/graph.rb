require 'json'

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
