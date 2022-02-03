class WordList
  attr_reader :answers, :guesses

  def initialize(answers_file:, guesses_file: nil, word_length: nil)
    @answers = File.readlines(answers_file).map(&:chomp)
    guesses = guesses_file ? File.readlines(guesses_file).map(&:chomp) : []
    if word_length
      @answers = @answers.grep(/^[a-z]{#{word_length}}$/)
      guesses = guesses.grep(/^[a-z]{#{word_length}}$/)
    end
    @guesses = (@answers + guesses).sort
  end

  def pick_word
    @answers.sample
  end

  def in_list?(guess)
    @guesses.bsearch {|wd| guess <=> wd }
  end

  def inspect
    "#<WordList with #{@answers.length} answers and #{@guesses.length} guesses>"
  end
end