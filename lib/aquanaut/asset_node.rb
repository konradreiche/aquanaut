require 'aquanaut/page_node'

module Aquanaut
  class AssetNode < PageNode

    attr_reader :type

    def initialize(uri, type)
      @type = type
      super(uri)
    end

  end
end
