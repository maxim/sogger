require 'helper'

class TestSogger < Test::Unit::TestCase
  context "Sogger" do
    should "have an SO_FEED_URL" do
      assert Sogger::SO_FEED_URL
    end
    
    should "have a save_path" do
      assert Sogger.save_path
    end
    
    context "populated with data" do
      setup do
        @sogger = Sogger.new
        @sogger.download_feed!
      end
      
      should "retrieve feed from #{Sogger::SO_FEED_URL}" do
        assert_equal read_sample_file('so_feed_sample.xml'), @sogger.raw_data
      end
      
      should "parse collection of 30 questions" do
        assert_equal 30, @sogger.questions.size
      end
      
      should "return question objects in questions collection" do
        assert_equal Question, @sogger.questions.first.class
      end
      
      should "have questions always sorted" do
        newer_question = Question.new(:published => DateTime.parse("12/12/2009"))
        older_question = Question.new(:published => DateTime.parse("12/12/2008"))
        @sogger.instance_variable_set("@questions", [older_question, newer_question])
        assert_equal [newer_question, older_question], @sogger.questions
      end
      
      should "save feed" do
        @sogger.save!
        assert File.exists?(Sogger.save_path)
      end
      
      should "load feed" do
        @sogger.save!
        sogger2 = Sogger.new
        sogger2.load!
        assert_equal read_sample_file('so_feed_sample.xml'), sogger2.raw_data
      end
      
      should "return new question when subtracted from another sogger" do
        very_new_question1 = Question.new(:published => DateTime.parse("12/12/2012"))
        very_new_question2 = Question.new(:published => DateTime.parse("12/12/2010"))
        very_old_question = Question.new(:published => DateTime.parse("12/12/1999"))
        fixture_question = Question.new(:published => DateTime.parse("2009-12-06T07:14:23Z"))
        
        collection = [very_old_question, very_new_question1, fixture_question, very_new_question2]
        newer_sogger = Sogger.new(collection)
        
        expected_difference = [very_new_question1, very_new_question2]
        actual_difference = (newer_sogger - @sogger).questions
        
        expected_inspect = expected_difference.map{|q| q.published.strftime('%d/%m/%y %H:%M:%S')}.inspect
        actual_inspect = actual_difference.map{|q| q.published.strftime('%d/%m/%y %H:%M:%S')}.inspect
        
        assert_equal expected_difference, actual_difference, 
          "Expected #{expected_inspect}, but was #{actual_inspect}."
      end
    end
  end
end
