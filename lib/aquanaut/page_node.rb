require 'aquanaut/node'

module Aquanaut
  class PageNode < Node

    attr_reader :uri

    def initialize(uri)
      @uri = uri
      super()
    end

  end
end
