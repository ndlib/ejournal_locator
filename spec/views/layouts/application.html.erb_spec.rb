require "spec_helper"

describe "layouts/application.html.erb" do
  before do
    # Method provided by blacklight controller
    view.stub(:has_user_authentication_provider?)
  end

  it "should render" do
    render
  end
end
