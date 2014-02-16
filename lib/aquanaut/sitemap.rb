require 'pathname'
require 'slim'

class Aquanaut::Sitemap

  def initialize(graph, domain, target_dir='sitemap')
    @graph = graph
    @domain = domain
    @target_dir = target_dir

    if Pathname.new(target_dir).relative?
      @target_dir = File.expand_path("../../../#{target_dir}", __FILE__)
    end
  end

  def render_results
    initialize_target_directory

    template_path = File.expand_path('../templates/index.html.slim', __FILE__)
    rendered_template = Slim::Template.new(template_path).render(self)

    File.open("#{@target_dir}/index.html", 'w') do |file|
      file.write rendered_template
    end
  end

  private
  def initialize_target_directory
    # create result directory
    Dir.mkdir(@target_dir) unless Dir.exists?(@target_dir)

    # copy vendor assets
    vendor_dir = File.expand_path('../../../vendor/assets', __FILE__)
    FileUtils.cp_r(vendor_dir, @target_dir, remove_destination: true)
  end

end
