#!/usr/bin/env ruby

require 'csv'
require 'set'
require_relative './word_list'
require_relative './wordle_clues'
require_relative './wordle_pattern'

word_list = WordList.default

if ARGV.count > 1 && ARGV.count.even?
  clues = ARGV.each_slice(2).sum(WordleClues.new) do |guess, pattern_colours|
    WordlePattern.new(guess: guess, colours: pattern_colours).to_clues
  end
  options = clues.filter_words(WordList.default.answers)
  puts options
  puts "No possible answers found in default list with those clues" if options.empty?
else
  STDERR.puts "usage: #{$0} WORD PATTERN [...]"
  STDERR.puts "e.g.: #{$0} wordy G.y.. words G.y.G"
  abort
end
