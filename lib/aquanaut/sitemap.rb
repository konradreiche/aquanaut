require 'pathname'
require 'slim'

# The sitemap class is used to render the results in HTML and JavaScript.
# 
# Uses SLIM as a template engine.
#
class Aquanaut::Sitemap

  def initialize(graph, domain, target_dir="#{Dir.pwd}/sitemap")
    @graph = graph
    @domain = domain
    @target_dir = target_dir

    if Pathname.new(target_dir).relative?
      @target_dir = File.expand_path("../../../#{target_dir}", __FILE__)
    end
  end

  # Renders the results by initiailizing the dependencies and processingt the template.
  #
  def render_results
    initialize_target_directory

    options = { disable_escape: true }
    template_path = File.expand_path('../templates/index.html.slim', __FILE__)
    rendered_template = Slim::Template.new(template_path, options).render(self)

    File.open("#{@target_dir}/index.html", 'w') do |file|
      file.write rendered_template
    end
  end

  private

  # There are several asset files required. Vendor asset files, but also local
  # asset files. They need to the copied to the target directory in order to
  # work properly.
  #
  # @private
  #
  def initialize_target_directory
    # create result directory
    Dir.mkdir(@target_dir) unless Dir.exists?(@target_dir)

    # copy vendor assets
    vendor_dir = File.expand_path('../../../vendor/assets', __FILE__)
    FileUtils.cp_r(vendor_dir, @target_dir, remove_destination: true)

    # copy local assets
    assets_dir = File.expand_path('../templates/assets', __FILE__)
    FileUtils.cp_r(assets_dir, @target_dir)
  end

end
