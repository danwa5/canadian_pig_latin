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

  describe '#translate' do
    context 'when words contain only letters' do
      let(:input) { 'Words contain only letters' }
      it 'translates every word correctly' do
        expect(subject.translate(input)).to eq('Ordsway ontaincay onlyyay etterslay')
      end
    end
    context 'when words end in punctuation (,.?!)' do
      let(:input) { 'Words, contain. some? commas!' }
      it 'translates every word correctly' do
        expect(subject.translate(input)).to eq('Ordsway, ontaincay. omesay? ommascay!')
      end
    end
    context 'string containing only whitespace' do
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
