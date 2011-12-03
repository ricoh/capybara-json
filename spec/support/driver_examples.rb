require 'capybara/spec/driver'

[ 'driver', 'driver with header support' ].each do |shared|
  RSpec.world.shared_example_groups.delete(shared)
end

shared_examples_for 'driver' do
  describe '#visit' do
    it "should move to another page" do
      @driver.visit('/')
      @driver.body.should include('Hello world!')
      @driver.visit('/foo')
      @driver.body.should include('Another World')
    end

    it "should show the correct URL" do
      @driver.visit('/foo')
      @driver.current_url.should include('/foo')
    end
  end

  describe '#body' do
    it "should return json reponses" do
      @driver.visit('/')
      @driver.body.should include('Hello world!')
    end
    # pending encoding
  end

  # TODO: find by jsonpath?
end

shared_examples_for 'driver with header support' do
  it "should make headers available through response_headers" do
    @driver.visit('/')
    @driver.response_headers['Content-Type'].should =~ /^application\/json/
  end
end
