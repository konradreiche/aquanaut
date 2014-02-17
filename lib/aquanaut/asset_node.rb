require 'aquanaut/page_node'

module Aquanaut

  # An asset node is a node that represents a static asset. The type specifies
  # what kind of static asset it is, for instance image or stylesheet.
  class AssetNode < PageNode

    attr_reader :type

    # Constructor
    #
    # @param [URI] uri identifying the static asset uniquely.
    #
    # @param [String] type specifying the kind of static asset.
    #
    def initialize(uri, type)
      @type = type
      super(uri)
    end

  end
end
