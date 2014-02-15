require 'mechanize'
require 'public_suffix'

class Aquanaut::Worker

  def initialize(target)
    uri = URI.parse(target)
    @queue = [uri]
    @domain = PublicSuffix.parse(uri.host)

    @agent = Mechanize.new
    @visited = Hash.new(false)
  end
  
  # Triggers the crawling process.
  #
  def explore
    while not @queue.empty?
      uri = @queue.shift  # dequeue

      # Visit URI
      @visited[uri] = true

      links(uri).each do |link|
        @queue.push(link)  # enqueue
      end
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
    page.links.map do |link|
      reference = URI.join(page.uri, link.uri)
      header = @agent.head(reference)

      location = header.uri
      next unless internal?(location)
      
      location
    end.compact
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
