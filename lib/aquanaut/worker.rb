require 'mechanize'
require 'public_suffix'

class Aquanaut::Worker

  def initialize(target)
    uri = URI.parse(target)
    @queue = [uri]
    @domain = PublicSuffix.parse(uri.host)

    @visited = Hash.new(false)
    @grabbed = Hash.new(false)

    @agent = Mechanize.new do |agent|
      agent.open_timeout = 5
      agent.read_timeout = 5
    end
  end
  
  # Triggers the crawling process.
  #
  def explore
    while not @queue.empty?
      uri = @queue.shift  # dequeue

      @visited[uri] = true
      puts "Visit #{uri}"

      links, assets = links(uri)
      links.each do |link|
        @queue.push(link) unless @visited[link]  # enqueue
      end

      yield uri, links, assets if block_given?
    end
  end

  # Retrieves all links from a given page.
  #
  # @param uri [URI] the URI from which the page is retrieved.
  #
  # @return [Array<URI>] list of links found on the given page.
  #
  def links(uri)
    page = @agent.get(uri)
    return [] unless page.is_a?(Mechanize::Page)

    assets = page.images.map do |image|
      uri = URI.join(page.uri, image.url)
      { 'uri' => uri, 'type' => 'image' }
    end

    page.parser.css('link[rel="stylesheet"]').each do |stylesheet|
      uri = URI.join(page.uri, stylesheet['href'])
      asset = { 'uri' => uri, 'type' => 'styleshet' }
      assets << asset
    end

    links = page.links.map do |link|
      begin
        next if link.uri.nil?
        reference = URI.join(page.uri, link.uri)

        next if @grabbed[reference]
        header = @agent.head(reference)

        location = header.uri
        next if not internal?(location) or not header.is_a?(Mechanize::Page)

        @grabbed[reference] = true
        @grabbed[location] = true
        
        location
      rescue Mechanize::Error, URI::InvalidURIError,
        Net::HTTP::Persistent::Error, Net::OpenTimeout, Net::ReadTimeout
        next
      end
    end.compact

    return links, assets
  rescue Mechanize::Error, Net::OpenTimeout, Net::ReadTimeout,
    Net::HTTP::Persistent::Error
    return [], []  # swallow
  end

  # Evaluates if a link stays in the initial domain.
  #
  # Used to keep the crawler inside the initial domain. In order to determinate
  # it uses the second-level and top-level domain. If the public suffix cannot
  # be detected due to possibly invalidity returns true to make sure the link
  # does not go unchecked.
  # 
  # @param link [URI] the link to be checked.
  #
  # @return [Boolean] whether the link is internal or not.
  #
  def internal?(link)
    return true unless PublicSuffix.valid?(link.host)
    link_domain = PublicSuffix.parse(link.host)
    @domain.sld == link_domain.sld and @domain.tld == link_domain.tld
  end

end
