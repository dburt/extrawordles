#!/usr/bin/env ruby

require 'csv'
require 'set'
require 'pathname'
require_relative './word_list'
require_relative './wordle_clues'
require_relative './wordle_pattern'

# word_list = WordList.default
word_list = WordList.new(answers_file: 'gnt-words.txt')

# starting_words = %[
#   tired loans chump
#   tired loans jumpy
#   tired loans
#   tared loins
#   tired
#   raise
#   aloes
#   salet
#   slane
#   slate
#   trace
# ].lines.map {|line| line.chomp.split }

# starting_words = %[
#   αυλην μερος πιστω
#   ιερον λυσης πατμω
#   εστως μηρον πυλαι
#   μυλος πασων τηρει
#   αυλην μωρος πιστε
#   μεσον πυλαι ρητως
#   ερμην πιστω υαλος
#   εορτη μισων πυλας
#   λυσον πατει ρωμης
#   εορτη πυλας σιμων
# ].lines.map {|line| line.chomp.split }

# pp starting_words

module Enumerable
  def average
    sum / count.to_f
  end

  def median
    sorted = sort
    if count.odd?
      sorted[count / 2]
    else
      sorted.values_at(count / 2, count / 2 + 1).average
    end
  end

  def guess_stats(answers = WordList.default.answers)
    guesses = self
    remaining_answers_by_answer = answers.map do |answer|
      clues = guesses.sum(WordleClues.new) {|guess|
        WordlePattern.from_guess(answer, guess).to_clues }
      clues.filter_words(answers).count
    end
    total_information = Math.log2(answers.count)
    information_by_answer = remaining_answers_by_answer.map do |n|
      Math.log2(n)
    end
    {
      worst_case: remaining_answers_by_answer.max,
      average_remaining: remaining_answers_by_answer.average,
      median_remaining: remaining_answers_by_answer.median,
      average_info: information_by_answer.average,
      median_info: information_by_answer.median,
    }
  end
end

answers = word_list.answers
stats_headings = %w(worst_case average_remaining median_remaining average_info median_info)
best = {}
CSV(STDOUT) do |csv|
  csv << ["words"] + stats_headings
  loop do
  # starting_words.each do |guesses|
    guesses = word_list.guesses.sample(2)
    next unless guesses.join.chars.uniq.length > 8
    stats = guesses.guess_stats(answers)
    csv << [
      guesses.join(' '),
      *stats_headings.map {|stat| stats[stat.to_sym] }
    ]
  end
end
