require 'spec_helper'

describe Freetext do
  let(:good) { ['Mars', 'Mercury', 'Lander']}
  let(:bad) { ['Marsha', 'Mary', 'Maurice', 'Lance', 'Lary']}
  let(:text) { "Marsha and Lance were the first aboard the Mars Lunar Lander."}
  let(:opts) { {good: good, bad: bad} }
  let(:ana) {Freetext::Analyzer.new(opts)}

  describe Freetext::Analyzer do

    context '#initialize' do
      it 'should accept and expose a hash of known good and bad words' do
        ana.good.should == good
        ana.bad.should == bad
      end

      it 'should initialize a bayesian classifer' do
        ana.classifier.should be_kind_of(Classifier::Bayes)
      end
    end

    it '#train! should train the classifier on the basis of the good and bad wordlist' do
      ana.train!
      ana.classifier.categories.should == ["Good", "Bad"]
    end

    context '#analyze' do
      it '#analyze should classify a good word as good and vice versa' do
        bad.map{|word| ana.analyze(word) == 'Bad'}
        good.map{|word| ana.analyze(word).should == 'Good'}
      end

      it '#analyze should train the classifier unless its already trained' do
        ana.classifier.instance_variable_get(:@category_counts).should be_empty
        ana.analyze "test"
        ana.classifier.instance_variable_get(:@category_counts).should == {:Good=>good.size, :Bad=>bad.size}
      end

    end
  end

  describe Freetext::Anonymizer do
    let(:anon) { Freetext::Anonymizer.new(opts) }

    context 'initialize' do
      before do
        ana.train!
      end

      it 'should accept a wordlist, initialize an analyzer with them' do
        anon.analyzer.should be_kind_of(Freetext::Analyzer)
        anon.analyzer.good.should == opts[:good]
        anon.analyzer.bad.should == opts[:bad]
      end

      it 'should alternatively accept an existing analyzer' do
        f = Freetext::Anonymizer.new(analyzer: ana)
        f.analyzer.should == ana
      end

      it 'should de-marshal given analyzer if necessary' do
        f = Freetext::Anonymizer.new(analyzer: Marshal.dump(ana))
        f.analyzer.stats.should == ana.stats
      end

      it 'should complain if not given either' do
        expect{Freetext::Anonymizer.new({})}.to raise_error(ArgumentError)
      end
    end

    context '#anonymize' do
      it 'should anonymize'

    end

    it '#dump should marshal and return a trained classifier for later use' do
      dump = anon.dump
      dump.should be_kind_of(String)
      Marshal.load(dump).should be_kind_of(Freetext::Analyzer)
    end

    it '#load should load marshalled classifer' do
      dump = anon.dump
      anon.load dump
      anon.analyzer.should be_kind_of(Freetext::Analyzer)
    end
  end
end