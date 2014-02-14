require 'aquanaut'
require 'spec_helper'
require 'webmock/rspec'

describe Aquanaut::Worker do
  describe "#initialize" do
    it "initializes the queue with the target address" do
      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      queue = worker.instance_variable_get('@queue')
      expected_queue = [URI.parse(target)]
      expect(queue).to eq(expected_queue)
    end

    it "stores the target address in its different components" do
      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      domain = worker.instance_variable_get('@domain')
      expect(domain.tld).to eq('com')
      expect(domain.sld).to eq('example')
      expect(domain.trd).to eq('www')
    end    
  end

  describe "#internal?" do
    it "compares second-level and top-level domain" do
      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      uri = URI.parse('http://www.example.com')
      expect(worker.internal?(uri)).to be_true

      uri = URI.parse('http://blog.example.com')
      expect(worker.internal?(uri)).to be_true

      uri = URI.parse('http://www.not-example.com')
      expect(worker.internal?(uri)).to be_false
    end

    it "guards against invalid domains" do
      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      uri = URI.parse('/internal.html')
      expect(worker.internal?(uri)).to be_true
    end
  end

  describe "#links" do
    it "retrieves no links from a page with no body" do
      response = { headers: { 'Content-Type' => 'text/html'} }
      stub_request(:get, 'www.example.com').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      uri = URI.parse('http://www.example.com')
      expect(worker.links(uri)).to be_empty
    end

    it "returns a list of URIs for a page with anchor elements" do
      body = <<-BODY
      <a href="/home.html">Home</a>
      <a href="/about.html">About us</a>
      <a href="/contact.html">Contact</a>
      BODY

      response = { body: body, headers: { 'Content-Type' => 'text/html'} }
      stub_request(:get, 'www.example.com').to_return(response)

      uris = ['http://www.example.com/home.html',
              'http://www.example.com/about.html',
              'http://www.example.com/contact.html']
      uris.map! { |uri| URI.parse(uri) }

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      uri = URI.parse('http://www.example.com')
      expect(worker.links(uri)).to eq(uris)
    end
  end
end
