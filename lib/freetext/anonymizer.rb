require 'classifier'
require "freetext/anonymizer/version"

module Freetext
  class Analyzer  # this should really be called Classifer, but collides with Classifier::Bayes
    attr_accessor :good, :bad, :classifier
    def initialize opts
      self.good, self.bad = opts[:good], opts[:bad]
      self.classifier = Classifier::Bayes.new 'good', 'bad'
    end

    def train type
      self.send(type).map{|word| classifier.send "train_#{type}", word }
    end

    def train!
      ['good', 'bad'].map{|t| train(t)}
    end

    def trained?
      @trained ||= classifier.instance_variable_get(:@category_counts).any?
    end

    def stats
      instance_variable_get(:@category_counts)
    end

    def analyze word
      train! unless trained?
      classifier.classify word
    end
  end

  class Anonymizer
    attr_accessor :analyzer

    def initialize opts={}
      raise ArgumentError.new(%Q{You must initialize with either a list of known good words and known bad words to anonymize,
        or an existing Freetext::Analyzer.  Example:
        Freetext::Analyzer.new({good: ['mars'], bad: ['marsha']})
        ...or
        Freetext::Analyzer.new({analyzer: Freetext::Analyzer.new})}) unless opts[:bad] || opts[:analyzer]

      self.analyzer = set_analyzer opts
    end

    def set_analyzer opts
      # binding.pry
      analyzer = opts.delete(:analyzer)

      if analyzer.is_a?(String)
        load(analyzer)
      elsif analyzer.is_a?(Analyzer)
        analyzer
      else
        Analyzer.new(opts)
      end
    end

    def dump
      Marshal.dump(analyzer)
    end

    def load analyzer_string
      Marshal.load(analyzer_string)
    end

    def readfile(file); File.open(file){|f| f.read }.split; end;

    def classify c, name
      res = readfile "wordlist/#{name}"
    # binding.pry
      res.map{|word| c.send "train_#{name}", word }
    end


    def create_classifier
      c = Classifier::Bayes.new 'good', 'bad'
      classify c, 'good'
      classify c, 'bad'

      text = File.open('text_responses','r:iso8859-1'){|f| f.read}.split("\n")
    end

    def remove_names c, text
      bads = []
      text.shuffle[0..200].each do |comment|
        puts "\n\n----------------------------------------------------------"
        puts "Processing: \n#{comment}\n"
        comment.gsub(/[.,?!-\(|\);"\n\-]+/, ' ').split.each do |word|
          res = c.classify word
          if res == 'Bad'
            bads << word
            puts "\n#{word} considered to be #{res}\n"
          end
        end
        # raise
      end
      puts
      puts "Bads: #{bads.uniq.sort.join("\n")}\n"
    end

    def remove_numbers text
      puts "\n-------- phones ------\n"
      phone_regex = /([ 0-9\.\-\+\(\)x]{3,15})/
      any_digit_greater_than_3_regex = /(0-9){4,50}/
      any_numbers = /([0-9]+)/

      [phone_regex, any_digit_greater_than_3_regex].each do |regex|
        text.each do |line|
          if matches = line.gsub(/\.\./,' ').match(regex)
            if matches[1].size > 5
              puts "found phone: #{matches[1]}"
            end
          end
        end
      end
    end

    def remove_emails text
      puts "\n-------- emails ------\n"
      email_regex = /(\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,10}\b)/i
      any_with_amp_after = /(@\w+\.)/

      [email_regex,any_with_amp_after].each do |regex|
        text.each do |line|
          if matches = line.gsub(/\.\./,' ').match(regex)
            if matches[1].size > 3
              puts "found email: #{matches[1]}"
            end
          end
        end
      end
    end

  end
end
