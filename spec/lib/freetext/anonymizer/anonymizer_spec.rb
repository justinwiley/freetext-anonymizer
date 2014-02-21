require 'spec_helper'

describe Freetext do

  describe Classifier do
    let(:good) { ['Mars', 'Lander']}
    let(:bad) { ['Marsha', 'Lance']}
    let(:text) { "Marsha and Lance were the first aboard the Lunar Lander."}

    let(:c) {Freetext::Classifier.new({good: good, bad: bad})}

    context '#initialize' do
      it 'should accept and expose a hash of known good and bad words' do
        c.good.should == good
        c.bad.should == bad
      end

      it 'should complain if not given either'
    end

    context 'classification' do
      it '#train! should train the classifier on the basis of the good and bad wordlist'

      it '#classify should classify a good word as good'

      it '#classify should classify a bad word as bad'
    end
  end

  describe Freetext::Anonymizer do
    context 'initialization' do
      it 'should initialize with a list of known good and bad words, create classifier'

      it 'should alternatively accept a previouslly trained classifer'
    end

    context '#anonymize' do
      it 'should accept a string of text, remove known bad, return'

      it 'should accept should not remove known good'
    end

    it '#dump should marshal and return a trained classifier for later use' do

    end
  end
end