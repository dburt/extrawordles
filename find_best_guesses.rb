#!/usr/bin/env ruby

require 'csv'
require_relative './word_list'
require_relative './wordle_clues'
require_relative './wordle_pattern'

# word_list = WordList.default
word_list = WordList.new(answers_file: 'gnt-words.txt')

class Pool  # from https://stackoverflow.com/a/17188457
  def initialize(size)
    @size = size
    @jobs = Queue.new
    @pool = Array.new(@size) do |i|
      Thread.new do
        Thread.current[:id] = i
        catch(:exit) do
          loop do
            job, args = @jobs.pop
            job.call(*args)
          end
        end
      end
    end
  end

  def schedule(*args, &block)
    @jobs << [block, args]
  end

  def shutdown
    @size.times do
      schedule { throw :exit }
    end
    @pool.map(&:join)
  end
end
pool = Pool.new(8)

unless defined?([].tally)
  module Enumerable
    def tally
      inject(Hash.new { 0 }) do |h, elem|
        h[elem] += 1
        h
      end
    end
  end
end

# {[guess1, guess2] => {answers_remaining => number_of_answers}}
h = Hash.new {|h, k| h[k] = Hash.new { 0 } }
answers = word_list.answers.select {|word| word.chars.uniq.length == word.length }
n = answers.length
puts
answers.each_with_index do |answer, i|
  answers.each_with_index do |guess1, j|
    print "\r#{i + 1}.#{j + 1}/#{answers.length} - #{answer} #{guess1}"
    clues1 = WordlePattern.from_guess(answer, guess1).to_clues
    answers_remaining1 = clues1.filter_words(answers)
    answers.each do |guess2|
      pool.schedule do
        clues2 = WordlePattern.from_guess(answer, guess2).to_clues
        answers_remaining2 = clues2.filter_words(answers_remaining1).length
        h[[guess1, guess2]][answers_remaining2] += 1
      end
    end
    ## csv << [answer, guess1, *guess2_answers_remaining]
  end
end
pool.shutdown
require 'json'
File.open("reports/best_guesses2.json", "w") do |f|
  f.write JSON.dump(h)
end

exit

#####################################

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

CSV.open("reports/best_guesses.csv", "w") do |csv|
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
