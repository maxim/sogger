module Sogger
  class Question
    include Comparable
    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end      
    
    def self.from_xml(xml_element)
      attributes = { :title => xml_element.css('title').text,
                     :url => xml_element.css('id').text,
                     :tags => xml_element.css('category').map{|c| c['term']},
                     :published => DateTime.parse(xml_element.css('published').text) }
      new attributes
    end
    
    def title
      @attributes[:title]
    end
    
    def url
      @attributes[:url]
    end
    
    def tags
      @attributes[:tags]
    end
    
    def published
      @attributes[:published]
    end
    
    def <=>(other)
      other.published <=> published
    end
  end
end