require 'aquanaut'
require 'spec_helper'
require 'webmock/rspec'

describe Aquanaut do

  describe ".process_domain" do
    it "builds a graph with pages as nodes and interlinks as edges" do
      body = <<-BODY
      <a href="/home.html">Home</a>
      <a href="/about.html">About us</a>
      BODY

      uri = URI.parse('http://www.example.com')

      response = { body: body, headers: { 'Content-Type' => 'text/html'} }
      stub_request(:get, 'www.example.com').to_return(response)

      stub_request(:get, 'www.example.com').to_return(response)

      stub_request(:head, 'www.example.com/home.html').to_return(response)
      stub_request(:get, 'www.example.com/home.html').to_return(response)

      stub_request(:head, 'www.example.com/about.html').to_return(response)
      stub_request(:get, 'www.example.com/about.html').to_return(response)

      graph = Aquanaut.process_domain('http://www.example.com')
      
      uris = ['http://www.example.com/home.html',
              'http://www.example.com/about.html'].map { |u| URI.parse(u) }

      root_node = graph[uri]
      page_1_node = graph[uris[0]]
      page_2_node = graph[uris[1]]

      expect(root_node).to be_an_instance_of(Aquanaut::PageNode)
      expect(page_1_node).to be_an_instance_of(Aquanaut::PageNode)
      expect(page_2_node).to be_an_instance_of(Aquanaut::PageNode)

      adjacency_list = [page_1_node, page_2_node]
      expect(root_node.adjacency_list).to eq(adjacency_list)

      expect(page_1_node.adjacency_list).to be_empty
      expect(page_2_node.adjacency_list).to be_empty
    end
  end

end
