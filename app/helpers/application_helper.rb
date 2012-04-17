module ApplicationHelper

  # Includes the relevant library SSI file from https://www.library.nd.edu/ssi/<filename>.shtml
  def include_ssi(filename)
    render :partial => "/layouts/include_ssi", :locals => {:filename => filename}
  end

  def read_ssi_file(filename)
    require 'open-uri'
    ssi_url = "http://www.library.nd.edu/ssi/#{filename}.shtml"
    f = open(ssi_url, "User-Agent" => "Ruby/#{RUBY_VERSION}")
    contents = f.read
    contents = contents.gsub(/(href|src)="\//,"\\1=\"https://www.library.nd.edu/")
    contents
  end
end
