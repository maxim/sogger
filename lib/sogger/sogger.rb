module Sogger
  class Sogger
    class << self; attr_accessor :save_path end
    attr_reader :raw_data
    
    SO_FEED_URL = "http://stackoverflow.com/feeds"
    DEFAULT_SAVE_PATH = "tmp/feed.xml"
    self.save_path = DEFAULT_SAVE_PATH
    
    def initialize(questions = [])
      @questions = questions
    end
    
    def questions
      @questions.sort
    end

    def download_feed!
      @raw_data = open(SO_FEED_URL).read
      parse_raw_data
    end
    
    def save!
      File.open(self.class.save_path, "w") do |file|
        file.write @raw_data
      end
    end
    
    def load!
      @raw_data = File.read(self.class.save_path)
      parse_raw_data
    end
    
    def -(other)
      newest_other = other.questions.first
      Sogger.new(questions.select{|q| q < newest_other })
    end
    
    private
    def parse_raw_data
      @data = Nokogiri::XML(@raw_data)
      @questions = @data.css('entry').map{ |e| Question.from_xml(e) }
    end
  end
end