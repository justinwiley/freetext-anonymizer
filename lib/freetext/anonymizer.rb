require "freetext/freetext"

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
    attr_accessor :analyzer, :tokenizer

    def initialize opts={}
      raise ArgumentError.new(%Q{You must initialize with either a list of known good words and known bad words to anonymize,
        or an existing Freetext::Analyzer.  Example:
        Freetext::Analyzer.new({good: ['mars'], bad: ['marsha']})
        ...or
        Freetext::Analyzer.new({analyzer: Freetext::Analyzer.new})}) unless opts[:bad] || opts[:analyzer]

      self.analyzer = set_analyzer opts
      self.tokenizer = Tokenizer::Tokenizer.new
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

    def anonymize text, opts={}
      {emails: true, phones: true, urls: true, replace: true}.each do |k,v|
        opts[k] ||= v
      end

      text.split.each do |sentence|
        
      end

      binding.pry


      # bads = []
      # text.split.each do |sentence|
      #   sentence.gsub(/[.,?!-\(|\);"\n\-]+/, ' ').split.each do |word|
      #     res = c.classify word
      #     if res == 'Bad'
      #       bads << word
      #       puts "\n#{word} considered to be #{res}\n"
      #     end
      #   end
      #   # raise
      # end
      # puts
      # puts "Bads: #{bads.uniq.sort.join("\n")}\n"
    end

  end
end
