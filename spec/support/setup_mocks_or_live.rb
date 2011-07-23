unless ENV['LIVE']
  # By default the Koala specs are run using stubs for HTTP requests
  #
  # Valid OAuth token and code are not necessary to run these
  # specs.  Because of this, specs do not fail due to Facebook
  # imposed rate-limits or server timeouts.
  #
  # However as a result they are more brittle since
  # we are not testing the latest responses from the Facebook servers.
  # Therefore, to be certain all specs pass with the current
  # Facebook services, run koala_spec_without_mocks.rb.
  Koala.http_service = Koala::MockHTTPService  
  KoalaTest.setup_test_data(Koala::MockHTTPService::TEST_DATA)
else
  # Runs Koala specs through the Facebook servers
  #
  # load testing data (see note in readme.md)  
  KoalaTest.setup_test_data(YAML.load_file(File.join(File.dirname(__FILE__), '../fixtures/facebook_data.yml')))
  
  # use a test user unless the developer wants to test against a real profile
  if token = KoalaTest.oauth_token
    KoalaTest.validate_user_info(token)
  else
    KoalaTest.setup_test_user
  end
end

# set up a global before block to set the token for tests
# set the token up for 
RSpec.configure do |config|
  config.before :each do
    @token = KoalaTest.oauth_token
  end
  
  config.after :each do
    # clean up any objects posted to Facebook
    if @temporary_object_id #&& real_user?
      puts "Cleaning up #{@temporary_object_id}"
      api = @api || (@test_users ? @test_users.graph_api : nil)
      raise "Unable to locate API when passed temporary object to delete!" unless api

      # clean up any objects we've posted
      result = (api.delete_object(id) rescue false)
      # if we errored out or Facebook returned false, track that
      puts "Encountered error when cleaning up #{@temporary_object_id}: #{result}" unless result
    end
  end
end


