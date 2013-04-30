require "spec_helper"

describe "layouts/application.html.erb" do
  before do
    # Method provided by blacklight controller
    view.stub(:has_user_authentication_provider?)
    view.stub(:search_field_options_for_select).and_return("")
  end

  it "should render" do
    render
  end
end
