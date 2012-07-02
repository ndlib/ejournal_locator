module ApplicationHelper

  # Includes the relevant library SSI file from http://www.library.nd.edu/ssi/<filename>.shtml
  def include_ssi(filename)
    render :partial => "/layouts/include_ssi", :locals => {:filename => filename}
  end

  def read_ssi_file(filename)
    require 'open-uri'
    ssi_url = "http://www.library.nd.edu/ssi/#{filename}.shtml"
    f = open(ssi_url, "User-Agent" => "Ruby/#{RUBY_VERSION}")
    contents = f.read
    if filename == "js"
      contents = clean_ssi_js(contents)
    end
    contents = contents.gsub(/(href|src)="\//,"\\1=\"https://www.library.nd.edu/")
    contents
  end

  # Since we're in the context of a Rails application with its own javascript assets, we want to remove any library site javascripts we don't need
  def clean_ssi_js(contents)
    contents.gsub(/^.*(jquery|simplegallery).*$/,"")
  end
end
