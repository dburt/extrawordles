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

  def clues_from_guesses(answer, guesses)
    @clues_from_guesses ||= {}
    @clues_from_guesses[[answer, *guesses]] ||= begin
      guesses.sum(WordleClues.new) {|guess|
        WordlePattern.from_guess(answer, guess).to_clues }
    end
  end

  def guess_stats(answers = WordList.default.answers)
    guesses = self
    remaining_answers_by_answer = answers.map do |answer|
      clues = clues_from_guesses(answer, guesses)
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
      percentile_90: remaining_answers_by_answer.percentile(0.90),
      percentile_95: remaining_answers_by_answer.percentile(0.95),
      percentile_99: remaining_answers_by_answer.percentile(0.99),
    }
  end
end

answers = word_list.answers
stats_headings = %w(worst_case average_remaining median_remaining percentile_1 percentile_2 percentile_5 percentile_10
  average_info_remaining median_info_remaining percentile_90 percentile_95 percentile_99)
single_word_stats = []
best = {}
CSV.open("reports/best_starting_words_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.csv", "w") do |csv|
  csv << ["words"] + stats_headings

  puts "Evaluating given words and phrases"
  starting_words.each do |guesses|
    stats = guesses.guess_stats(answers)
    csv << [ guesses.join(' '), *stats_headings.map {|stat| stats[stat.to_sym] } ]
    csv.flush
  end

  # puts "Evaluating all single word guesses"
  # guesses = word_list.guesses
  # guesses.each_with_index do |guess, i|
  #   stats = [guess].guess_stats(answers)
  #   single_word_stats << [ guess, *stats_headings.map {|stat| stats[stat.to_sym] } ]
  #   csv << single_word_stats.last
  #   csv.flush
  #   print "\r#{i+1}/#{guesses.count}"
  # end

  puts "Evaluating all pairs of possible answers"
  word_list.answers.each_with_index do |guess1, i|
    word_list.answers.each_with_index do |guess2, j|
      print "\r#{i+1}:#{j+1}/#{word_list.answers.length + 1}"
      next if guess1 == guess2
      guesses = [guess1, guess2]
      stats = guesses.guess_stats(answers)
      csv << [ guesses.join(' '), *stats_headings.map {|stat| stats[stat.to_sym] } ]
      csv.flush
    end
  end

  # select smaller list of better starting words
  # CSV.foreach("reports/best_starting_words.csv") do |row|
  #   words, *stats = row.to_a
  #   next if words == "words" || words.length != 5
  #   single_word_stats << [words, *stats.map(&:to_f)]
  # end
  # single_word_stats.sort_by! {|row| row[8].to_f }  # average_info_remaining

  # best = stats_headings.zip(stats_headings.map {|stat| 999_999 }).to_h
  # puts "Try multiple guesses"
  # single_word_stats[0, single_word_stats.length / 2].each_with_index do |(guess, *stats), i|
  #   print "\r#{i+1}/#{single_word_stats.length / 3 + 1}"
  #   100.times do
  #     guesses = [guess, *word_list.guesses.sample(2)]
  #     stats = guesses.guess_stats(answers)
  #     next unless stats_headings.any? {|stat| stats[stat.to_sym] < best[stat] }
  #     stats_headings.each {|stat| best[stat] = [stats[stat.to_sym], best[stat]].min }
  #     csv << [ guesses.join(' '), *stats_headings.map {|stat| stats[stat.to_sym] } ]
  #     csv.flush
  #   end
  # end

  # puts "Evaluating random word pairs"
  # loop do
  #   guesses = word_list.guesses.sample(2)
  #   next unless guesses.join.chars.uniq.length > 8
  #   print "."
  #   stats = guesses.guess_stats(answers)
  #   csv << [ guesses.join(' '), *stats_headings.map {|stat| stats[stat.to_sym] } ]
  # end
end

