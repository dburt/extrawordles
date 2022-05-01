#!/usr/bin/env ruby

require 'csv'
require 'set'
require 'pathname'
require_relative './word_list'
require_relative './wordle_clues'
require_relative './wordle_pattern'

word_list = WordList.default
# word_list = WordList.new(answers_file: 'gnt-words.txt')

starting_words = %[
  aahed
  tired loans chump
  tired loans jumpy
  tired loans
  tared loins
  tired
  raise
  aloes
  salet
  slane
  slate
  trace
].lines.map {|line| line.chomp.split }

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

  def percentile(n)
    raise ArgumentError, "n must be within 0..1" unless n.between?(0, 1)
    sorted = sort
    index = n * (count + 1)
    if index == index.to_i
      sorted[index]
    else
      sorted.values_at(index, index + 1).average
    end
  end

  def median
    percentile(0.5)
  end

  def guess_stats(answers = WordList.default.answers)
    guesses = self
    remaining_answers_by_answer = answers.map do |answer|
      clues = guesses.sum(WordleClues.new) {|guess|
        WordlePattern.from_guess(answer, guess).to_clues }
      clues.filter_words(answers).count
    end
    information_by_answer = remaining_answers_by_answer.map do |n|
      Math.log2(n)
    end
    {
      worst_case: remaining_answers_by_answer.max,
      average_remaining: remaining_answers_by_answer.average,
      median_remaining: remaining_answers_by_answer.median,
      percentile_1: remaining_answers_by_answer.percentile(0.01),
      percentile_2: remaining_answers_by_answer.percentile(0.02),
      percentile_5: remaining_answers_by_answer.percentile(0.05),
      percentile_10: remaining_answers_by_answer.percentile(0.10),
      average_info_remaining: information_by_answer.average,
      median_info_remaining: information_by_answer.median,
    }
  end
end

answers = word_list.answers
stats_headings = %w(worst_case average_remaining median_remaining percentile_1 percentile_2 percentile_5 percentile_10
  average_info_remaining median_info_remaining)
best = {}
CSV.open("reports/best_starting_words.csv", "w") do |csv|
  csv << ["words"] + stats_headings

  puts "Evaluating given words and phrases"
  starting_words.each do |guesses|
    stats = guesses.guess_stats(answers)
    csv << [ guesses.join(' '), *stats_headings.map {|stat| stats[stat.to_sym] } ]
  end

  puts "Evaluating all single word guesses"
  guesses = word_list.guesses
  guesses.each_with_index do |guess, i|
    stats = [guess].guess_stats(answers)
    csv << [ guess, *stats_headings.map {|stat| stats[stat.to_sym] } ]
    print "\r#{i+1}/#{guesses.count}"
  end

  # TODO: start with best single words, add a set of random second words working down the list
  # TODO: record only improvements

  # random words
  puts "Evaluating random word pairs"
  loop do
    guesses = word_list.guesses.sample(2)
    next unless guesses.join.chars.uniq.length > 8
    print "."
    stats = guesses.guess_stats(answers)
    csv << [ guesses.join(' '), *stats_headings.map {|stat| stats[stat.to_sym] } ]
  end
end

