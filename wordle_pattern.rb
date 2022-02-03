class WordlePattern
  attr_reader :guess, :colours

  def initialize(answer, guess)  # guess
    @guess = guess
    @colours = guess.chars.each_with_index.map do |c, i|
      if answer[i] == c
        :green
      elsif answer.chars.include?(c)
        :yellow
      else
        :grey
      end
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
      case colour
      when :green
        "G"
      when :yellow
        "y"
      else
        "."
      end
    end.join
  end
end
