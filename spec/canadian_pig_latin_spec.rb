require 'spec_helper'

describe CanadianPigLatin do
  it 'has a version number' do
    expect(CanadianPigLatin::VERSION).not_to be nil
  end

  describe '.translate' do
    let(:input) { 'word' }
    it 'calls #translate with argument' do
      expect_any_instance_of(described_class).to receive(:translate).with(input)
      described_class.translate(input)
    end
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
  end

  describe '#translate' do
    context 'argument is present' do
      let(:input) { 'Hows it going over there? Hey, you know what? This argument contains some words. Yay!' }
      it 'returns a translation' do
        expect(subject.translate(input).length).to be > 0
      end
    end
    context 'argument is string containing only whitespace' do
      let(:input) { '   ' }
      it 'returns an empty string' do
        expect(subject.translate(input)).to eq('')
      end
    end
  end

  describe '#translate_word' do
    let(:mapping) {
      {
        'Do' => 'Oday',
        'you' => 'ouyay',
        'know' => 'nowkay',
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
        expect(subject.translate_word(original)).to eq(translated)
      end
    end
  end

  describe '#insert_aboot' do
    context 'argument is empty array' do
      it 'returns an empty array' do
        expect(subject.insert_aboot([])).to be_empty
      end
    end
    context 'argument is given' do
      let(:input) { 'Hows it going over there? Hey, you know what? This argument contains some words. Yay!'.split(' ') }
      let(:number) { Math.sqrt(input.size/2).floor }
      it 'returns an array that contains the correct number of "aboot"' do
        expect(subject.insert_aboot(input).count('aboot')).to eq(number)
      end
      it 'returns an array where "aboot" does not begin a sentence' do
        expect(subject.insert_aboot(input).join(' ')).not_to match(/(^aboot.*|[\.\?!]+\saboot.*)/)
      end
      it 'returns an array where "aboot" does not end a sentence' do
        expect(subject.insert_aboot(input).join(' ')).not_to match(/(.*aboot[\.\?!]+|.*aboot$)/)
      end
    end
  end

  describe '#insert_ay' do
    context 'argument is empty array' do
      it 'returns an empty array' do
        expect(subject.insert_ay([])).to be_empty
      end
    end
    context 'argument is given' do
      let(:input) { 'Hows it going over there? Hey, you know what? This argument contains some words. Yay!'.split(' ') }
      it 'returns an array that contains the correct number of "ay!"' do
        expect(subject.insert_ay(input).count('ay!')).to eq(4)
      end
      it 'returns an array where "ay!" does not start a sentence' do
        expect(subject.insert_ay(input).join(' ')).not_to match(/(^ay!.*|.*ay! [a-z]+)/)
      end
    end
  end

  describe '#begins_with_vowel?' do
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
