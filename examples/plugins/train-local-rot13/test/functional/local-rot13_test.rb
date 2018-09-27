# Functional tests for the Train Local Rot13 Example Plugin.

# Functional tests are used to verify the behaviors of the plugin are as
# expected, to a user.

# For train, a "user" is a developer using your plugin to access things from
# their app. Unlike unit tests, we don't assume any knowledge of how anything
# works; we just know what it is supposed to do.

# Include our test harness
require_relative '../helper'

# Because InSpec is a Spec-style test suite, and Train has a close relationship
# to InSpec, we're going to use MiniTest::Spec here, for familiar look and
# feel. However, this isn't InSpec (or RSpec) code.
describe 'train-local-rot13' do
  # Our helper.rb locates this library from the Train install that
  # Bundler installed for us. If we want its methods, we still must
  # import it.  Including it here will make it available in all child
  # 'describe' blocks.
  include TrainPluginFunctionalHelper

  # When thinking up scenarios to test, start with the simplest.
  # Then think of each major feature, and exercise them.
  # Running combinations of features makes sense if it is very likely,
  # or a difficult / dangerous case.  You can always add more tests
  # here as users find subtle problems.  In fact, having a user submit
  # a PR that creates a failing functional test is a great way to
  # capture the reproduction case.

  # Some tests through here use minitest Expectations, which attach to all
  # Objects, and begin with 'must' (positive) or 'wont' (negative)
  # See https://ruby-doc.org/stdlib-2.1.0/libdoc/minitest/rdoc/MiniTest/Expectations.html

  # LocalRot13 should do at least this:
  # * Not explode when you run Train with it
  # * Apply rot13 when you use Train to read a file
  # * Apply rot13 when you use Train to run a command

  describe "creating a train instance with this transport" do
    # This is a bit of an awkward test. There is no 'wont_raise', so
    # we just execute the risky code; if it breaks, the test will be
    # registered as an Error.

    it "should not explode on create" do
      # This checks for uncaught exceptions.
      Train.create('local-rot13')

      # This checks for warnings (or any other output) to stdout/stderr
      proc { Train.create('local-rot13') }.must_be_silent
    end

    it "should not explode on connect" do
      # This checks for uncaught exceptions.
      Train.create('local-rot13').connection

      # This checks for warnings (or any other output) to stdout/stderr
      proc { Train.create('local-rot13').connection }.must_be_silent
    end
  end

  describe "reading a file" do
    it "should rotate the text by 13 positions" do
      conn = Train.create('local-rot13').connection
      # Here, plugin_fixtures_path is provided by the TrainPluginFunctionalHelper,
      # and refers to the absolute path to the test fixtures directory.
      # The file 'hello' simply has the text 'hello' in it.
      file_obj = conn.file(File.join(plugin_fixtures_path, 'hello'))
      file_obj.content.wont_include('hello')
      file_obj.content.must_include('uryyb')
    end
  end

  describe "running a command" do
    it "should rotate the stdout by 13 positions" do
      conn = Train.create('local-rot13').connection
      file_obj = conn.run_command('echo hello')
      file_obj.stdout.wont_include('hello')
      file_obj.stdout.must_include('uryyb')
    end
  end
end