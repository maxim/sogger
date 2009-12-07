require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sogger'

FakeWeb.register_uri :get, Sogger::Sogger::SO_FEED_URL, :body => File.read("test/fixtures/so_feed_sample.xml")

class Test::Unit::TestCase
  include Sogger
  def setup
    Sogger.save_path = "test/feed.xml"
  end

  def read_sample_file(filename)
    File.read("test/fixtures/#{filename}")
  end

  def teardown
    File.delete(Sogger.save_path) if File.exists?(Sogger.save_path)
  end
end
