require 'spec_helper'

describe "jobs/show.html.erb" do
  before(:each) do
    @job = assign(:job, stub_model(Job))
  end

  it "renders attributes in <p>" do
    render
  end
end
