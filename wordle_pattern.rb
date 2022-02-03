class WordlePattern
  attr_reader :guess, :colours

  COLOUR_CHARS = {green: 'G', yellow: 'y', grey: '.'}.freeze
  COLOUR_FROM_CHAR = COLOUR_CHARS.invert.freeze

  def self.from_guess(answer, guess)
    new(guess: guess, colours: colours_from_guess(answer, guess))
  end

  def self.colours_from_guess(answer, guess)
    guess.chars.each_with_index.map do |c, i|
      if answer[i] == c
        :green
      elsif answer.chars.include?(c)
        :yellow
      else
        :grey
      end
    end
  end

  def initialize(guess:, colours:)
    @guess = guess
    if colours.respond_to?(:chars)
      @colours = colours.chars.map {|c| COLOUR_FROM_CHAR[c] }
    else
      @colours = colours
    end
  end

  def to_clues  # pattern_to_clues
    clues = WordleClues.new
    guess.chars.zip(colours).each_with_index.all? do |(c, colour), i|
      case colour
      when :green
        clues.yes_chars << c
        clues.yes_positions << [c, i]
      when :yellow
        clues.yes_chars << c
        clues.no_positions << [c, i]
      else
        clues.no_chars << c
      end
    end
    clues
  end

  def ==(other)
    guess == other.guess && colours == other.colours
  end
  alias :eql? :==

  def hash
    [guess, colours].hash
  end

  def colours_as_word
    colours.map do |colour|
      COLOUR_CHARS[colour]
    end.join
  end
end
