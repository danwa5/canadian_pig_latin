require "canadian_pig_latin/version"

class CanadianPigLatin
  attr_reader :input, :country

  END_PUNCTUATION_REGEXP = /[\.\?!]+$/
  END_COMMA_REGEXP = /,+$/

  EXPRESSIONS = {
    'Canada' => { 'popular' => 'aboot', 'interjection' => 'ay!' },
    'USA' => { 'popular' => 'awesome', 'interjection' => 'dude!' },
    'Australia' => { 'popular' => 'freshie', 'interjection' => 'mate!' },
  }

  def self.translate(input='', options = {})
    if options.has_key?(:country) && !EXPRESSIONS.keys.include?(options[:country])
      raise ArgumentError, 'Please specify a valid country: Canada, USA, or Australia'
    end
    new(input, options).translate
  end

  def initialize(input, options)
    @input = input
    @country = options.fetch(:country, 'Canada')
  end

  def translate
    output = Array.new
    words = input.split(' ')
    words.each do |word|
      output << translate_word(word)
    end
    output = insert_popular_word(output)
    output = insert_interjection(output)
    output.join(' ')
  end

  def translate_word(word)
    translated = if begins_with_vowel?(word)
      "#{word}yay"
    else
      "#{word[1..-1]}#{word[0]}ay"
    end

    data = word.match(END_PUNCTUATION_REGEXP) || word.match(END_COMMA_REGEXP)
    if data
      translated.sub!(data[0], '')
      translated << data[0]
    end

    capitalized?(word) ? translated.downcase.capitalize : translated
  end

  def insert_popular_word(words)
    return words if words.empty?
    # Get array of indices for words that do not end in . or ? or !
    indices = words.each_index.select { |index| !capitalized?(words[index]) && !words[index].match(END_PUNCTUATION_REGEXP) }

    # Get the number of times to insert an 'aboot'
    num_aboots = Math.sqrt(indices.size/2).floor

    # Choose the words to insert 'aboot' after, and then insert
    aboot_indices = indices.sample(num_aboots).sort
    aboot_indices.each_with_index do |index, offset|
      words.insert(index+offset+1, EXPRESSIONS[country]['popular'])
    end
    words
  end

  def insert_interjection(words)
    return words if words.empty?
    # Get array of indices for words that end in . or ? or !
    indices = words.each_index.select { |index| words[index].match(END_PUNCTUATION_REGEXP) }

    # Insert interjection at the end of a sentence
    indices.each_with_index do |index, offset|
      words[index+offset].sub!(END_PUNCTUATION_REGEXP, ',')
      words.insert(index+offset+1, EXPRESSIONS[country]['interjection'])
    end
    words
  end

  def begins_with_vowel?(word)
    word.match(/^[aeiouAEIOU]/) ? true : false
  end

  def capitalized?(word)
    word.match(/^[A-Z]/) ? true : false
  end
end
