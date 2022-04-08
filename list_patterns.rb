#!/usr/bin/env ruby

require 'csv'
require_relative './word_list'
# require_relative './wordle_clues'
require_relative './wordle_pattern'

word_list = WordList.default

CSV.open("patterns.csv", "w") do |csv|
  csv << %w(answer guess pattern_colours)
  word_list.answers.each_with_index do |answer, index|
    print "\r#{ index + 1 }/#{ word_list.answers.count }"
    word_list.guesses.each do |guess|
      csv << [answer, guess, WordlePattern.from_guess(answer, guess).colours_as_word]
    end
  end
end
