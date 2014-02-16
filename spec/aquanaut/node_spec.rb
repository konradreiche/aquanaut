require 'aquanaut'
require 'spec_helper'

describe Aquanaut::Node do

  describe "#initialize" do
    it "initializes an empty adjacency list" do
      node = Aquanaut::Node.new
      expect(node.adjacency_list).to be_empty
    end
  end

  describe "#add_edge" do
    it "adds a successor to the adjacency list" do
      node = Aquanaut::Node.new
      adjacent_node = Aquanaut::Node.new

      expect do
        node.add_edge(adjacent_node)
      end.to change { node.adjacency_list.count }.by(1)

      expect(node.adjacency_list.first).to eq(adjacent_node)
    end
  end

end
