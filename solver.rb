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
# CSV.open('reports/solutions0.csv', 'w') do |csv|
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
# CSV.open('reports/solutions1.csv', 'w') do |csv|
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
# %w(opera aesir adieu raise).each do |initial_guess|
# %w(salet slane slate trace crane crate roast raise shark pious).each do |initial_guess|  # 3Blue1Brown, mum, dad

#   puts initial_guess

#   CSV.open("reports/solutions2-#{initial_guess}+.csv", 'w') do |csv|
#     csv << %w(initial_guess pattern guess worst_case_words_left)
#     initial_patterns = word_list.answers.group_by do |answer|
#       WordlePattern.from_guess(answer, initial_guess)
#     end
#     initial_patterns.each_with_index do |(initial_pattern, answers), i|
#       print "\r#{i}/#{initial_patterns.length} patterns - -/- guesses    "
#       initial_clues = initial_pattern.to_clues
#       initial_options_remaining = initial_clues.filter_words(word_list.answers)

#       # FIXME: should check here to see if there is only one answer left, and shortcut the loop
#       # guesses = initial_clues.filter_words(word_list.guesses)

#       guesses = word_list.guesses

#       guesses.each_with_index do |guess, j|
#         print "\r#{i}/#{initial_patterns.length} patterns - #{j}/#{guesses.length} guesses    "
#         patterns_seen = Set.new
#         worst_case_words_left = answers.map do |answer|
#           pattern = WordlePattern.from_guess(answer, guess)
#           next 0 if patterns_seen.include?(pattern)
#           patterns_seen << pattern
#           clues = pattern.to_clues
#           options_remaining = clues.filter_words(initial_options_remaining)
#           options_remaining.size
#         end.max
#         csv << [initial_guess, initial_pattern.colours_as_word, guess, worst_case_words_left]
#         # csv.flush
#       end
#     end
#   end
#   puts "done"
# end

#
# Third word: Given the first two words and their patterns, are we close to forcing a solution?
#

require 'pry'

%w(aloes later).each do |starting_word|
# %w(aloes).each do |starting_word|
  guesses_by_pattern = {}
  CSV.foreach("reports/solutions2-trimmed-#{starting_word}.csv", headers: true) do |row|
    hash = guesses_by_pattern[row['pattern']] ||= {worst_case: 999, guesses: []}
    case row['worst_case_words_left'].to_i <=> hash[:worst_case]
    when -1
      hash[:worst_case] = row['worst_case_words_left'].to_i
      hash[:guesses] = [row['guess']]
    when 0
      hash[:guesses] << row['guess']
    when 1
      # ignore worse options
    end
  end

  # # Check to see if already solved, because we forgot to do that in the solutions2+ step
  # guesses_by_pattern.select {|pattern, hash| hash[:worst_case] == 1}.each do |pattern, hash|
  #   clues = WordlePattern.new(guess: starting_word, colours: pattern).to_clues
  #   options = clues.filter_words(word_list.answers)
  #   if options.length == 1
  #     hash[:guesses] = options
  #     hash[:worst_case] = 0
  #   end
  # end

  # CSV.open("reports/solutions2-trimmed-#{starting_word}.csv", "w") do |csv|
  #   csv << %w(initial_guess pattern guess worst_case_words_left)
  #   guesses_by_pattern.each do |pattern, hash|
  #     hash[:guesses].each do |guess|
  #       csv << [starting_word, pattern, guess, hash[:worst_case]]
  #     end
  #   end
  # end

  CSV.open("reports/solutions3-#{starting_word}.csv", "w") do |csv|
    csv << %w(guess1 pattern1 guess2 pattern2 guess3 worst_case_words_left)
    guesses_by_pattern.each do |pattern, hash|
      if hash[:worst_case] == 0
        # already done
        csv << [starting_word, pattern, hash[:guesses].first, 'GGGGG', nil, 0]
      else
        pattern1 = WordlePattern.new(guess: starting_word, colours: pattern)
        clues1 = pattern1.to_clues
        options1 = clues1.filter_words(word_list.answers)

        guess3s_by_pattern2 = {}

        hash[:guesses].each do |guess2|
          # word_list.guesses.each do |guess3|
          options1.each do |guess3|

            next if guess3 < guess2  # commutative so no need to test both ways

            print "\r#{starting_word} #{initial_pattern.colours_as_word} #{guess} ????? #{next_guess}"
            options1.each do |answer|
              pattern2 = WordlePattern.from_guess(answer, guess2)
              clues2 = pattern2.to_clues
              next 0 if patterns_seen.include?(next_pattern)
              patterns_seen << next_pattern
              clues = pattern.to_clues + next_pattern.to_clues
              options2 = clues.filter_words(options1)
              options2.size
            end

            hash = guesses_by_pattern[row['pattern']] ||= {worst_case: 999, guesses: []}
            case worst_case_words_left <=> hash[:worst_case]
            when -1
              hash[:worst_case] = worst_case_words_left
              hash[:guesses] = [next_guess]
            when 0
              hash[:guesses] << next_guess
            when 1
              # ignore worse options
            end

            csv << [starting_word, initial_pattern.colours_as_word, guess, pattern.colours_as_word, next_guess, worst_case_words_left]
          end

        end
      end
    end
  end

end
