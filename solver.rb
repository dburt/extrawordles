#!/usr/bin/env ruby

require 'csv'
require 'set'
require_relative './word_list'
require_relative './wordle_clues'
require_relative './wordle_pattern'
# require_relative './wordle_helper'

#
# What are the best words to start with?
# Which guesses reduce the pool of remaining answers the best?
# Which guesses minimise the remaining possible answers, if the answer gives the worst-case clue-pattern response 
#


word_list = WordList.default

word_count = word_list.guesses.size

#
# First pass: the blank pattern (no matches) usually (but not always) provides the worst-case scenario
# and is much quicker than matching against all the possible answers.
#
# CSV.open('solutions0.csv', 'w') do |csv|
#   csv << %w(guess worst_case_words_left)
#   word_list.guesses.each_with_index do |guess, i|
#     print "\r#{i}/#{word_count}"
#     clues = WordlePattern.new("#####", guess).to_clues
#     worst_case_words_left = clues.filter_words(word_list.answers).size
#     csv << [guess, worst_case_words_left]
#     csv.flush
#   end
# end
# puts " done"

#
# Do it properly: find the worst-case remaining possibilities even when there's a yellow in the pattern
#
# CSV.open('solutions1.csv', 'w') do |csv|
#   csv << %w(guess worst_case_words_left)
#   word_list.guesses.each_with_index do |guess, i|
#     print "\r#{i}/#{word_count}"
#     patterns_seen = Set.new
#     worst_case_words_left = word_list.answers.map do |answer|
#       pattern = WordlePattern.new(answer, guess)
#       next 0 if patterns_seen.include?(pattern)
#       patterns_seen << pattern
#       clues = pattern.to_clues
#       options_remaining = clues.filter_words(word_list.answers)
#       options_remaining.size
#     end.max
#     csv << [guess, worst_case_words_left]
#     csv.flush
#   end
# end
# puts " done"

#
# What is the best second word, given a first guess and a pattern response?
#

# initial_guess = "toned"
# %w(arise toned).each do |initial_guess|
# %w(aeons tyler tared aloes later teary laser).each do |initial_guess|
%w(opera aesir adieu raise).each do |initial_guess|

  puts initial_guess

  CSV.open("solutions2-#{initial_guess}+.csv", 'w') do |csv|
    csv << %w(initial_guess pattern guess worst_case_words_left)
    initial_patterns = word_list.answers.group_by do |answer|
      WordlePattern.from_guess(answer, initial_guess)
    end
    initial_patterns.each_with_index do |(initial_pattern, answers), i|
      print "\r#{i}/#{initial_patterns.length} patterns - -/- guesses    "
      initial_clues = initial_pattern.to_clues
      initial_options_remaining = initial_clues.filter_words(word_list.answers)

      guesses = word_list.guesses
      # guesses = initial_clues.filter_words(word_list.guesses)

      guesses.each_with_index do |guess, j|
        print "\r#{i}/#{initial_patterns.length} patterns - #{j}/#{guesses.length} guesses    "
        patterns_seen = Set.new
        worst_case_words_left = answers.map do |answer|
          pattern = WordlePattern.from_guess(answer, guess)
          next 0 if patterns_seen.include?(pattern)
          patterns_seen << pattern
          clues = pattern.to_clues
          options_remaining = clues.filter_words(initial_options_remaining)
          options_remaining.size
        end.max
        csv << [initial_guess, initial_pattern.colours_as_word, guess, worst_case_words_left]
        # csv.flush
      end
    end
  end
  puts "done"
end

#
# Third word: Given the first two words and their patterns, are we close to forcing a solution?
#
