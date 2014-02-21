require "freetext/anonymizer/version"

module Freetext
  class Classifier
    attr_accessor :good, :bad
    def initialize opts
      raise ArgumentError.new("Must pass in a list of good words, that should not be anonymized/removed") unless opts[:good]
      raise ArgumentError.new("Must pass in a list of bad words, that should be anonymized/removed") unless opts[:bad]
      self.good, self.bad = opts[:good], opts[:bad]
    end
  end

  class Anonymizer

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
