require "canadian_pig_latin/version"

class CanadianPigLatin
  def self.translate(input='')
    new.translate(input)
  end

  def translate(input)
    output = Array.new
    words = input.split(' ')
    words.each do |word|
      output << translate_word(word)
    end
    output.join(' ')
  end

  def translate_word(word)
    data = word.match(/[\.\?!,]+$/)

    translated = if begins_with_vowel?(word)
      "#{word}yay"
    else
      "#{word[1..-1]}#{word[0]}ay"
    end

    if data
      translated.sub!(data[0], '')
      translated << data[0]
    end

    capitalized?(word) ? translated.downcase.capitalize : translated
  end

  def begins_with_vowel?(word)
    word.match(/^[aeiouAEIOU]/) ? true : false
  end

  def capitalized?(word)
    word.match(/^[A-Z]/) ? true : false
  end
end
