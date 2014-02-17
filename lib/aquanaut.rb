require 'aquanaut/asset_node'
require 'aquanaut/graph'
require 'aquanaut/page_node'
require 'aquanaut/sitemap'
require 'aquanaut/version'
require 'aquanaut/worker'

# Main module
#
module Aquanaut
  class << self

    # Processes the given target domain and creates a page and asset graph.
    #
    # @param [String] target_adress
    #
    def process_domain(target_address)
      worker = Worker.new(target_address)
      graph = Graph.new

      worker.explore do |page_uri, links, static_assets|
        graph.add_node(PageNode.new(page_uri))

        links.each do |link_uri|
          graph.add_node(PageNode.new(link_uri))
          graph.add_edge(page_uri, link_uri)
        end

        static_assets.each do |asset|
          graph.add_node(AssetNode.new(asset['uri'], asset['type']))
          graph.add_edge(page_uri, asset['uri'])
        end
      end

      return graph
    end

  end
end
