module Aquanaut
  class Node

    attr_reader :adjacency_list

    def initialize()
      @adjacency_list = []
    end

    def add_edge(successor)
      @adjacency_list << successor
    end

  end
end
