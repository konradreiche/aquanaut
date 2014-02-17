require 'aquanaut/node'

module Aquanaut
  class PageNode < Node

    attr_reader :uri

    def initialize(uri)
      @uri = uri
      super()
    end

    def display
      part = "#{@uri.path}#{@uri.query}#{@uri.fragment}"
      part = @uri.to_s if part.empty?
      return part
    end

  end
end
