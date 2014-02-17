module Aquanaut

  # Base node class which needs to be inherited for special cases.
  #
  # @abstract
  #
  class Node

    attr_reader :adjacency_list

    def initialize()
      @adjacency_list = []
    end

    # Implements adjacency with an adjacency list.
    #
    def add_edge(successor)
      @adjacency_list << successor
    end

  end
end
