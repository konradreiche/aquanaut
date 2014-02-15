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

      stub_request(:get, 'www.example.com').to_return(response)

      stub_request(:head, 'www.example.com/home.html').to_return(response)
      stub_request(:get, 'www.example.com/home.html').to_return(response)

      stub_request(:head, 'www.example.com/about.html').to_return(response)
      stub_request(:get, 'www.example.com/about.html').to_return(response)

      stub_request(:head, 'www.example.com/contact.html').to_return(response)
      stub_request(:get, 'www.example.com/contact.html').to_return(response)

      stub_request(:head, 'www.not-example.com').to_return(response)

      uris = ['http://www.example.com/home.html',
              'http://www.example.com/about.html',
              'http://www.example.com/contact.html']

      uris.map! { |uri| URI.parse(uri) }

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      uri = URI.parse('http://www.example.com')
      expect(worker.links(uri)).to eq(uris)
    end

    it "returns the final location when encountering HTTP 3xx" do
      body = '<a href="http://follow-me.com">Follow me</a>'
      response = { body: body, headers: { 'Content-Type' => 'text/html'} }
      stub_request(:get, 'www.example.com').to_return(response)
    end

    it "filters links that reference an external domain directly" do
      body = <<-BODY
      <a href="/home.html">Home</a>
      <a href="/about.html">About us</a>
      <a href="/contact.html">Contact</a>
      <a href="http://www.not-example.com">Not Example</a>
      BODY

      response = { body: body, headers: { 'Content-Type' => 'text/html'} }

      stub_request(:get, 'www.example.com').to_return(response)

      stub_request(:head, 'www.example.com/home.html').to_return(response)
      stub_request(:get, 'www.example.com/home.html').to_return(response)

      stub_request(:head, 'www.example.com/about.html').to_return(response)
      stub_request(:get, 'www.example.com/about.html').to_return(response)

      stub_request(:head, 'www.example.com/contact.html').to_return(response)
      stub_request(:get, 'www.example.com/contact.html').to_return(response)

      stub_request(:head, 'www.not-example.com').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      uris = ['http://www.example.com/home.html',
              'http://www.example.com/about.html',
              'http://www.example.com/contact.html']

      uris.map! { |uri| URI.parse(uri) }

      uri = URI.parse('http://www.example.com')
      expect(worker.links(uri)).to eq(uris)
    end

    it "filters links that reference an external domain indirectly" do
        body = <<-BODY
        <a href="/home.html">Home</a>
        <a href="/about.html">About us</a>
        <a href="/contact.html">Contact</a>
        <a href="/moved.html">Moved</a>
        BODY

        other_domain = 'http://www.not-example.com'
        response = { body: body, headers: { 'Content-Type' => 'text/html'} }
        forward = { status: 301, headers: { 'Location' => other_domain } }

        stub_request(:get, 'www.example.com').to_return(response)

        stub_request(:head, 'www.example.com/home.html').to_return(response)
        stub_request(:get, 'www.example.com/home.html').to_return(response)

        stub_request(:head, 'www.example.com/about.html').to_return(response)
        stub_request(:get, 'www.example.com/about.html').to_return(response)

        stub_request(:head, 'www.example.com/contact.html').to_return(response)
        stub_request(:get, 'www.example.com/contact.html').to_return(response)

        stub_request(:head, 'www.example.com/moved.html').to_return(forward)
        stub_request(:head, other_domain).to_return(response)

        target = 'http://www.example.com'
        worker = Aquanaut::Worker.new(target)

        uris = ['http://www.example.com/home.html',
                'http://www.example.com/about.html',
                'http://www.example.com/contact.html']

        uris.map! { |uri| URI.parse(uri) }

        uri = URI.parse('http://www.example.com')
        expect(worker.links(uri)).to eq(uris)
    end

    it "rejects errors raised by Mechanize when retrieving the page" do
      response = { status: 500 }
      stub_request(:get, 'www.example.com').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)
      uri = URI.parse(target)

      expect(worker.links(uri)).to be_empty
    end

    it "rejects errors raised by Mechanize when checking the links" do
      body = <<-BODY
      <a href="/home.html">Home</a>
      <a href="/about.html">About us</a>
      BODY

      headers = { 'Content-Type' => 'text/html'}

      response = { body: body, headers: headers }
      response_500 = { status: 500 }

      stub_request(:get, 'www.example.com').to_return(response)
      stub_request(:head, 'www.example.com/home.html').to_return(response)
      stub_request(:head, 'www.example.com/about.html').to_return(response_500)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)
      uri = URI.parse(target)

      uris = [URI.parse('http://www.example.com/home.html')]
      expect(worker.links(uri)).to eq(uris)
    end

    it "rejects invalid URIs" do
      body = '<a href="http:invalid.com">Invalid</a>'

      headers = { 'Content-Type' => 'text/html'}
      response = { body: body, headers: headers }

      stub_request(:get, 'www.example.com').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)
      uri = URI.parse(target)

      expect(worker.links(uri)).to be_empty
    end

    it "rejects anchors with no href attribute" do
      body = '<a>Empty</a>'

      headers = { 'Content-Type' => 'text/html'}
      response = { body: body, headers: headers }

      stub_request(:get, 'www.example.com').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)
      uri = URI.parse(target)

      expect(worker.links(uri)).to be_empty
    end

    it "rejects links that lead to a timeout" do
      body = '<a href="/timeout.html">Timeout</a>'

      headers = { 'Content-Type' => 'text/html'}
      response = { body: body, headers: headers }

      stub_request(:get, 'www.example.com').to_return(response)
      stub_request(:head, 'www.example.com/timeout.html').to_timeout

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)
      uri = URI.parse(target)

      expect(worker.links(uri)).to be_empty
    end

    it "rejects links that have already been grabbed" do
      body = <<-BODY
      <a href="/home.html">Home</a>
      <a href="/home.html">Home</a>
      BODY

      response = { body: body, headers: { 'Content-Type' => 'text/html'} }

      stub_request(:get, 'www.example.com').to_return(response)
      stub_request(:get, 'www.example.com/home.html').to_return(response)
      stub_request(:head, 'www.example.com/home.html').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)
      uri = URI.parse(target)

      result = [URI.parse('http://www.example.com/home.html')]
      expect(worker.links(uri)).to eq(result)
    end
  end

  describe "#explore" do
    it "starts the crawling by processing the first queue element" do
      response = { headers: { 'Content-Type' => 'text/html'} }
      stub_request(:get, 'www.example.com').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)
      worker.explore

      queue = worker.instance_variable_get('@queue')
      expect(queue).to be_empty
    end

    it "marks visited sites" do
      response = { headers: { 'Content-Type' => 'text/html'} }
      stub_request(:get, 'www.example.com').to_return(response)

      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      visited = worker.instance_variable_get('@visited')
      expect { worker.explore }.to change { visited.size }.by(1)
    end

    it "skips already visited sites" do
    end
  end
end
