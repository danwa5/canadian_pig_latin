require 'spec_helper'

describe CanadianPigLatin do
  it 'has a version number' do
    expect(CanadianPigLatin::VERSION).not_to be nil
  end

  describe 'constants' do
    describe 'END_PUNCTUATION_REGEXP' do
      it 'matches any trailing period, question mark, or exclamation point' do
        expect('dog.').to match(described_class::END_PUNCTUATION_REGEXP)
        expect('Goat???').to match(described_class::END_PUNCTUATION_REGEXP)
        expect('horse!.').to match(described_class::END_PUNCTUATION_REGEXP)
        expect('Pig.?!').to match(described_class::END_PUNCTUATION_REGEXP)
        expect('rabbit,').not_to match(described_class::END_PUNCTUATION_REGEXP)
      end
    end
    describe 'END_COMMA_REGEXP' do
      it 'matches any trailing comma' do
        expect('chicken,').to match(described_class::END_COMMA_REGEXP)
        expect('dog.').not_to match(described_class::END_COMMA_REGEXP)
        expect('Goat???').not_to match(described_class::END_COMMA_REGEXP)
        expect('horse!.').not_to match(described_class::END_COMMA_REGEXP)
        expect('Pig.?!').not_to match(described_class::END_COMMA_REGEXP)
        expect('turkey').not_to match(described_class::END_COMMA_REGEXP)
      end
    end
    describe 'EXPRESSIONS' do
      it 'has the correct keys' do
        expect(described_class::EXPRESSIONS.keys).to eq(['Canada', 'USA', 'Australia'])
      end
      it 'has the correct popular words' do
        expect(described_class::EXPRESSIONS['Canada']['popular']).to eq('aboot')
        expect(described_class::EXPRESSIONS['USA']['popular']).to eq('awesome')
        expect(described_class::EXPRESSIONS['Australia']['popular']).to eq('freshie')
      end
      it 'has the correct interjections' do
        expect(described_class::EXPRESSIONS['Canada']['interjection']).to eq('ay!')
        expect(described_class::EXPRESSIONS['USA']['interjection']).to eq('dude!')
        expect(described_class::EXPRESSIONS['Australia']['interjection']).to eq('mate!')
      end
    end
  end

  describe '.translate' do
    context 'with valid arguments' do
      it 'calls #translate' do
        expect_any_instance_of(described_class).to receive(:translate)
        described_class.translate
      end
    end
    context 'with invalid country' do
      it 'raises an exception' do
        expect do
          described_class.translate('blah', { country: 'NoSuchCountry' })
        end.to raise_error(ArgumentError, 'Please specify a valid country: Canada, USA, or Australia')
      end
    end
  end

  describe '#initialize' do
    context 'when input and country are not provided' do
      let(:subject) { described_class.new(nil, {}) }
      its(:input) { is_expected.to be_nil }
      its(:country) { is_expected.to eq('Canada') }
    end
    context 'when input and country are provided' do
      let(:subject) { described_class.new('word', { country: 'USA' }) }
      its(:input) { is_expected.to eq('word') }
      its(:country) { is_expected.to eq('USA') }
    end
  end

  describe '#translate' do
    subject { described_class.new(input, {})}
    context 'argument is present' do
      let(:input) { 'Hows it going over there? Hey, you know what? This argument contains some words. Yay!' }
      it 'returns a translation' do
        expect(subject.translate.length).to be > 0
      end
    end
    context 'argument is string containing only whitespace' do
      let(:input) { '   ' }
      it 'returns an empty string' do
        expect(subject.translate.length).to eq(0)
        expect(subject.translate).to eq('')
      end
    end
  end

  describe '#translate_word' do
    let(:mapping) {
      {
        'Do' => 'Oday',
        'you' => 'ouyay',
        'know' => 'nowkay',
        'how' => 'owhay',
        'to' => 'otay',
        'speak' => 'peaksay',
        'Canadian' => 'Anadiancay',
        'pig' => 'igpay',
        'latin' => 'atinlay',
        'anyway?' => 'anywayyay?',
        'If' => 'Ifyay',
        'not,' => 'otnay,',
        'everyone' => 'everyoneyay',
        'else' => 'elseyay',
        'can' => 'ancay',
        'teach' => 'eachtay',
        'you.' => 'ouyay.'
      }
    }
    it 'returns the correct translation for every word' do
      mapping.each do |original, translated|
        subject = described_class.new('', {})
        expect(subject.translate_word(original)).to eq(translated)
      end
    end
  end

  describe '#insert_popular_word' do
    context 'argument is empty array' do
      subject { described_class.new('', {}) }
      it 'returns an empty array' do
        expect(subject.insert_popular_word([])).to be_empty
      end
    end
    context 'argument is given' do
      let(:input) { 'Hows it going over there? Hey, you know what? This argument contains some words. Yay!'.split(' ') }
      let(:number) { Math.sqrt(input.size/2).floor }

      described_class::EXPRESSIONS.each do |country, value|
        popular_word = value['popular']
        context "country is #{country}" do
          subject { described_class.new(input, { country: country }) }
          it "returns an array that contains the correct number of '#{popular_word}'" do
            expect(subject.insert_popular_word(input).count(popular_word)).to eq(number)
          end
          it "returns an array where '#{popular_word}' does not begin a sentence" do
            expect(subject.insert_popular_word(input).join(' ')).not_to match(/(^#{popular_word}.*|[\.\?!]+\s#{popular_word}.*)/)
          end
          it "returns an array where '#{popular_word}' does not end a sentence" do
            expect(subject.insert_popular_word(input).join(' ')).not_to match(/(.*#{popular_word}[\.\?!]+|.*#{popular_word}$)/)
          end
        end
      end
    end
  end

  describe '#insert_interjection' do
    context 'argument is empty array' do
      subject { described_class.new('', {}) }
      it 'returns an empty array' do
        expect(subject.insert_interjection([])).to be_empty
      end
    end
    context 'argument is given' do
      let(:input) { 'Hows it going over there? Hey, you know what? This argument contains some words. Yay!'.split(' ') }

      described_class::EXPRESSIONS.each do |country, value|
        interjection = value['interjection']
        context "country is #{country}" do
          subject { described_class.new(input, { country: country }) }
          it "returns an array that contains the correct number of '#{interjection}'" do
            result = subject.insert_interjection(input)
            expect(result.count(interjection)).to eq(4)
          end
          it "returns an array where '#{interjection}' does not start a sentence" do
            expect(subject.insert_interjection(input).join(' ')).not_to match(/(^#{interjection}.*|.*#{interjection} [a-z]+)/)
          end
        end
      end
    end
  end

  describe '#begins_with_vowel?' do
    subject { described_class.new('', {}) }
    context 'word begins with vowel' do
      let(:words) { %w(Alligator elephant Iguana ostrich Urial) }
      it 'returns true' do
        words.each do |word|
          expect(subject.begins_with_vowel?(word)).to eq(true)
        end
      end
    end
    context 'word begins with consonant' do
      let(:words) { %w(Cat dog Goat horse Pig turkey) }
      it 'returns false' do
        words.each do |word|
          expect(subject.begins_with_vowel?(word)).to eq(false)
        end
      end
    end
  end

  describe '#capitalized?' do
    subject { described_class.new('', {}) }
    context 'first letter is capitalized' do
      let(:words) { %w(All Dogs Go To Heaven) }
      it 'returns true' do
        words.each do |word|
          expect(subject.capitalized?(word)).to eq(true)
        end
      end
    end
    context 'first letter is not capitalized' do
      let(:words) { %w(what is canadian pig latin?) }
      it 'returns false' do
        words.each do |word|
          expect(subject.capitalized?(word)).to eq(false)
        end
      end
    end
  end
end
