require "canadian_pig_latin/version"

class CanadianPigLatin
  END_PUNCTUATION_REGEXP = /[\.\?!]+$/
  END_COMMA_REGEXP = /,+$/

  def self.translate(input='')
    new.translate(input)
  end

  def translate(input)
    output = Array.new
    words = input.split(' ')
    words.each do |word|
      output << translate_word(word)
    end
    output = insert_aboot(output)
    output = insert_ay(output)
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

  def insert_aboot(words)
    return words if words.empty?
    # Get array of indices for words that do not end in . or ? or !
    indices = words.each_index.select { |index| !capitalized?(words[index]) && !words[index].match(END_PUNCTUATION_REGEXP) }

    # Get the number of times to insert an 'aboot'
    num_aboots = Math.sqrt(indices.size/2).floor

    # Choose the words to insert 'aboot' after, and then insert
    aboot_indices = indices.sample(num_aboots).sort
    aboot_indices.each_with_index do |index, offset|
      words.insert(index+offset+1, 'aboot')
    end
    words
  end

  def insert_ay(words)
    return words if words.empty?
    # Get array of indices for words that end in . or ? or !
    indices = words.each_index.select { |index| words[index].match(END_PUNCTUATION_REGEXP) }

    # Insert 'ay! at the end of a sentence'
    indices.each_with_index do |index, offset|
      words[index+offset].sub!(END_PUNCTUATION_REGEXP, ',')
      words.insert(index+offset+1, 'ay!')
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
