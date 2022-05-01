class WordlePattern
  attr_reader :guess, :colours

  COLOUR_CHARS = {green: 'G', yellow: 'y', grey: '.'}.freeze
  COLOUR_FROM_CHAR = COLOUR_CHARS.invert.freeze

  def self.from_guess(answer, guess)
    new(guess: guess, colours: colours_from_guess(answer, guess))
  end

  def self.colours_from_guess(answer, guess)
    yellows = yellows_count_by_letter(answer, guess)
    result = guess.chars.each_with_index.map do |c, i|
      if answer[i] == c
        :green
      elsif yellows[c] > 0
        yellows[c] -= 1
        :yellow
      else
        :grey
      end
    end
  end

  def self.matches_count_by_letter(answer, guess)
    answer_tally = answer.chars.tally
    guess.chars.tally.map do |c, n|
      [c, [n, answer_tally[c].to_i].min]
    end.to_h
  end

  def self.greens_count_by_letter(answer, guess)
    answer.chars.zip(guess.chars).map {|a, b| a if a == b }.tally
  end

  def self.yellows_count_by_letter(answer, guess)
    greens = greens_count_by_letter(answer, guess)
    matches_count_by_letter(answer, guess).map do |c, n|
      [c, n - greens[c].to_i]
    end.to_h
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
        clues.no_chars << c  # FIXME: should record a max count for that char in the clues
      end
    end
    (clues.no_chars & clues.yes_chars).each do |c|
      clues.no_chars.delete(c)
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
