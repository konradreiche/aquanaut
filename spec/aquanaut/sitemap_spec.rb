require 'aquanaut'
require 'spec_helper'

describe Aquanaut::Sitemap do
  
  describe "#initialize" do
    it "stores the given graph and domain" do
      graph = Aquanaut::Graph.new
      domain = 'http://www.example.com'
      sitemap = Aquanaut::Sitemap.new(graph, domain)

      expect(sitemap.instance_variable_get('@graph')).to be(graph)
      expect(sitemap.instance_variable_get('@domain')).to be(domain)
    end

    it "expands the path of the given target directory" do
      graph = Aquanaut::Graph.new
      domain = 'http://www.example.com'
      target_dir = 'spec/sitemap'

      sitemap = Aquanaut::Sitemap.new(graph, domain, target_dir)
      expanded_dir = sitemap.instance_variable_get('@target_dir')

      expect(Pathname.new(expanded_dir).absolute?).to be_true
      expect(expanded_dir.end_with?("/aquanaut/#{target_dir}")).to be_true
    end
  end

  describe "#initialize_target_directory" do
    it "creates the directory and copies assets file if neccessary" do
      graph = Aquanaut::Graph.new
      domain = 'http://www.example.com'
      target_dir = 'spec/sitemap'

      sitemap = Aquanaut::Sitemap.new(graph, domain, target_dir)
      sitemap.send(:initialize_target_directory)

      expect(Dir.exist?(target_dir)).to be_true
      expect(Dir.exist?("#{target_dir}/assets")).to be_true

      FileUtils.rm_r(target_dir)
    end
  end

  describe "#render_results" do
    it "the result rendering works for an empty graph" do
      graph = Aquanaut::Graph.new
      domain = 'http://www.example.com'
      target_dir = 'spec/sitemap'

      sitemap = Aquanaut::Sitemap.new(graph, domain, target_dir)
      sitemap.render_results

      expect(File.exist?("#{target_dir}/index.html"))

      FileUtils.rm_r(target_dir)
    end
  end

end
