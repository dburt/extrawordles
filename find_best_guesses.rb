#!/usr/bin/env ruby

require 'csv'
require_relative './word_list'
require_relative './wordle_clues'
require_relative './wordle_pattern'

# word_list = WordList.default

guesses = answers = %w(cigar
rebut
sissy
humph
awake
blush
focal
evade
naval
serve)

total_information = Math.log2(answers.count)
puts "Information required: #{total_information}"

class Array
  def average
    sum / count
  end
end

CSV.open("best_guesses.csv", "w") do |csv|
  csv << %w(guess1 guess2 average_information)
  guesses.each do |guess1|
    guesses.each do |guess2|
      next if guess1 > guess2
      ns = answers.map do |answer|
        clues = WordlePattern.from_guess(answer, guess1).to_clues + WordlePattern.from_guess(answer, guess2).to_clues
        clues.filter_words(answers).length
      end
      inf = ns.map {|n| Math.log2(n) }.average
      p [guess1, guess2, ns.min, ns.max, ns.average, total_information - inf]
    end
  end
end
