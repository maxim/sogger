module Sogger
  class Runner
    class << self
      attr_accessor :update_interval, :growl_interval, :logging
    end
    
    attr_reader :filter
    
    Runner.update_interval = 60
    Runner.growl_interval = 20
    Runner.logging = true
    
    def initialize(options = {})
      options[:update_interval] ||= Runner.update_interval
      options[:growl_interval] ||= Runner.growl_interval
      options[:logging] = options[:logging].nil? ? Runner.logging : options[:logging]
      
      Runner.update_interval = options[:update_interval]
      Runner.growl_interval = options[:growl_interval]
      Runner.logging = options[:logging]
      
      @filter = [*options[:filter]].compact
      @cached_sogger = Sogger.new
      @remote_sogger = Sogger.new
      @questions_buffer = []
      @growler = Meow.new("Sogger")
    end
    
    def run
      updater = Thread.new("updater") do
        while true
          log "Updater: Downloading feed..."
          @remote_sogger.download_feed!
      
          new_questions = []
          unless @cached_sogger.questions.empty?
            log "Updater: Comparing feeds..."
            new_questions = (@remote_sogger - @cached_sogger).questions
          end
      
          unless new_questions.empty?
            log "Updater: Adding #{new_questions.size} questions to buffer..."
            @questions_buffer += new_questions
          end
      
          log "Updater: Caching feed..."
          @remote_sogger.save!
      
          log "Updater: Loading cached feed..."
          @cached_sogger.load!
      
          log "Updater: Sleeping for #{Runner.update_interval} seconds..."
          sleep Runner.update_interval
        end
      end
      
      notifier = Thread.new("notifier") do
        while true
          unless @questions_buffer.empty?
            log "\nNotifier: Filtering questions..."
            while question = @questions_buffer.pop
              if @filter.empty? || question.tags.any?{ |t| @filter.include?(t) }
                log "\nNotifier: Growling..."
                growl(question)
                break
              end
            end
          end
          
          sleep Runner.growl_interval
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
    
    def log(text)
      puts text if Runner.logging
    end
  end
end