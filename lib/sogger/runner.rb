module Sogger
  class Runner
    UPDATE_INTERVAL = 60
    GROWL_INTERVAL = 20
    
    def initialize
      @cached_sogger = Sogger.new
      @remote_sogger = Sogger.new
      @questions_buffer = []
      @growler = Meow.new("Sogger")
    end
    
    def run
      updater = Thread.new("updater") do
        while true
          puts "Updater: Downloading feed..."
          @remote_sogger.download_feed!
      
          new_questions = []
          unless @cached_sogger.questions.empty?
            puts "Updater: Comparing feeds..."
            new_questions = (@remote_sogger - @cached_sogger).questions
          end
      
          unless new_questions.empty?
            puts "Updater: Adding #{new_questions.size} questions to buffer..."
            @questions_buffer += new_questions
          end
      
          puts "Updater: Caching feed..."
          @remote_sogger.save!
      
          puts "Updater: Loading cached feed..."
          @cached_sogger.load!
      
          puts "Updater: Sleeping for #{UPDATE_INTERVAL} seconds..."
          sleep UPDATE_INTERVAL
        end
      end
      
      notifier = Thread.new("notifier") do
        while true
          unless @questions_buffer.empty?
            puts "\nNotifier: Growling..."
            growl(@questions_buffer.pop)
          end
          
          sleep GROWL_INTERVAL
        end
      end
      
      trap("INT") do
        puts "  Exiting, please wait..."
        [updater, notifier].map(&:kill)
      end
      [updater, notifier].map(&:join)
    end
    
    def growl(question)
      @growler.notify(question.tags.join(', '), question.title) do
        system "open", question.url
      end
    end
  end
end