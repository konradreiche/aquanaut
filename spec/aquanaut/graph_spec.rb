require 'aquanaut'
require 'spec_helper'

describe Aquanaut::Graph do

  describe "#initialize" do
    it "initializes an empty nodes hash" do
      graph = Aquanaut::Graph.new
      expect(graph.instance_variable_get('@nodes')).to be_empty
    end
  end

  describe "#add_node" do
    it "adds the node and hashes the node based on its URI attribute" do
      uri = URI.parse('http://www.example.com')
      node = Aquanaut::PageNode.new(uri)

      graph = Aquanaut::Graph.new
      graph.add_node(node)

      expect(graph[node.uri]).to eq(node)
    end

    it "does not add a node if it already exists under the given URI" do
      uri = URI.parse('http://www.example.com')
      node = Aquanaut::PageNode.new(uri)
      same_node = Aquanaut::PageNode.new(uri)

      graph = Aquanaut::Graph.new
      graph.add_node(node)

      expect(graph[uri]).to be(node)
      expect(graph[uri]).to_not be(same_node)
    end
  end

  describe "#add_edge" do
    it "looks up the predecessor node and delegates to the node's method" do
      uri = URI.parse('http://www.example.com')
      node = Aquanaut::PageNode.new(uri)

      adjacent_uri = URI.parse('http://www.example.com/home.html')
      adjacent_node = Aquanaut::PageNode.new(adjacent_uri)

      graph = Aquanaut::Graph.new
      graph.add_node(node)
      graph.add_node(adjacent_node)
      graph.add_edge(uri, adjacent_uri)

      expect(graph[uri].adjacency_list.first).to eq(adjacent_node)
    end
  end

  describe "#[]" do
    it "looks up a node based on its URI" do
      uri = URI.parse('http://www.example.com')
      node = Aquanaut::PageNode.new(uri)

      graph = Aquanaut::Graph.new
      graph.add_node(node)

      expect(graph[uri]).to be(node)
    end
  end

end
