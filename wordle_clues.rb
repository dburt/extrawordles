class WordleClues
  attr_reader :yes_chars, :no_chars, :yes_positions, :no_positions

  def initialize(yes_chars: [], no_chars: [], yes_positions: [], no_positions: [])
    @yes_chars, @no_chars, @yes_positions, @no_positions = yes_chars, no_chars, yes_positions, no_positions
  end

  def +(other)  # learn
    new(
      yes_chars: (yes_chars + other.yes_chars).uniq,
      no_chars: (no_chars + other.no_chars).uniq,
      yes_positions: (yes_positions + other.yes_positions).uniq,
      no_positions: (no_positions + other.no_positions).uniq
    )
  end

  def =~(word)
    yes_positions.all? {|c, i| word[i] == c } &&
    yes_chars.all? {|c| word.include?(c) } &&
    no_chars.none? {|c| word.include?(c) } &&
    no_positions.none? {|c, i| word[i] == c }
  end

  def filter_words(words)
    words.select {|word| self =~ word }
  end
end
