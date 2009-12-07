require 'helper'

class TestQuestion < Test::Unit::TestCase
  context "Question" do
    setup do
      @xml_element = Nokogiri::XML(read_sample_file("so_feed_sample.xml")).css('entry').first
    end
    
    should "be initializeable from xml" do
      assert_nothing_raised do
        Question.from_xml(@xml_element)
      end
    end
    
    should "have correct attributes when instantiated from xml" do
      q = Question.from_xml(@xml_element)
      expected_attributes = {
        :title => "Windows and Minibuffer floating over the frame",
        :url => "http://stackoverflow.com/questions/1856203/windows-and-minibuffer-floating-over-the-frame",
        :tags => ["emacs"],
        :published => DateTime.parse("2009-12-06T18:48:09Z")}
      
      assert_equal expected_attributes, q.attributes
    end
    
    context "instance" do
      setup do
        @question = Question.from_xml(@xml_element)
      end
      
      should "have title attribute" do
        assert_equal "Windows and Minibuffer floating over the frame", @question.title
      end
      
      should "have url attribute" do
        assert_equal "http://stackoverflow.com/questions/1856203/windows-and-minibuffer-floating-over-the-frame", @question.url
      end
      
      should "have tags attribute" do
        assert_equal ["emacs"], @question.tags
      end
      
      should "have published attribute" do
        assert_equal DateTime.parse("2009-12-06T18:48:09+00:00"), @question.published
      end
    end
  end
  
  context "Array of questions" do
    setup do
      @newer_question = Question.new(:published => DateTime.parse("12/12/2009"))
      @older_question = Question.new(:published => DateTime.parse("12/12/2008"))
      @questions = [@older_question, @newer_question]
    end
    
    should "sort by published" do
      assert_equal [@newer_question, @older_question], @questions.sort
    end
  end
end
