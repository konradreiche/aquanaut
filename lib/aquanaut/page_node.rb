require 'aquanaut/node'

module Aquanaut

  # A page node represents an actual page in the specified domain.
  #
  class PageNode < Node

    attr_reader :uri

    def initialize(uri)
      @uri = uri
      super()
    end

    # Display method used on the front-end for the sitemap in list format.
    #
    def display
      part = "#{@uri.path}#{@uri.query}#{@uri.fragment}"
      part = @uri.to_s if part.empty?
      return part
    end

  end
end
