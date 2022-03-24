#!/usr/bin/env ruby

require 'csv'
require 'set'
require 'pathname'
require_relative './word_list'
require_relative './wordle_clues'
require_relative './wordle_pattern'

word_list = WordList.default
# word_list = WordList.new(answers_file: 'gnt-words.txt')

if ARGV == ["+"]
  # list worst case from best 2nd guess from each processed file
  Pathname.glob("reports/*.csv").each do |pathname|
    worst_case_from_best_next_guess = CSV.read(pathname.to_s, headers: true).
      group_by {|row| row['pattern'] }.
      map {|pattern, rows| rows.map {|row| row['worst_case_words_left'].to_i }.min }.
      max
    puts "#{pathname} - worst case from best next guess = #{worst_case_from_best_next_guess}"
  end
elsif ARGV.count == 2 && ARGV.join !~ /\W/
  # e.g. $0 tared loins
  guesses = ARGV
  answers = word_list.answers
  n = answers.map do |answer|
    clues = guesses.sum(WordleClues.new) {|guess| WordlePattern.from_guess(answer, guess).to_clues }
    clues.filter_words(answers).count
  end.max
  puts "Worst case: #{n} answers left"
elsif ARGV.count == 2 && File.exist?("reports/solutions2-#{ARGV[0]}.csv")
  # e.g. $0 arise G.y..
  guesses_by_worst_case_words_left = CSV.read("reports/solutions2-#{ARGV[0]}.csv", headers: true).
    select {|row| row['pattern'] == ARGV[1] }.
    group_by {|row| row['worst_case_words_left'].to_i }
  best_worst_case = guesses_by_worst_case_words_left.keys.min
  puts "Best worst case: #{best_worst_case}"
  puts "Guesses:"
  puts guesses_by_worst_case_words_left[best_worst_case].map {|row| row['guess'] }
elsif ARGV.count > 1 && ARGV.count.even?
  # e.g. $0 tared G.y.. loins ...yy
  clues = ARGV.each_slice(2).sum(WordleClues.new) do |guess, pattern_colours|
    WordlePattern.new(guess: guess, colours: pattern_colours).to_clues
  end
  options = clues.filter_words(word_list.answers)
  # FIXME: 🐛:
  # $ ./helper2.rb tired ..yG. loans .y... order G..GG
  # No possible answers found in default list with those clues
  # $ ./helper2.rb tired ..yG. loans .y...
  # offer
  puts options
  if options.empty?
    puts "No possible answers found in default list with those clues"
  elsif options.count > 2
    puts "Finding best guess to differentiate..."
    guesses_by_words_left = word_list.guesses.group_by do |guess|
      options.map do |answer|
        clues = WordlePattern.from_guess(answer, guess).to_clues
        remaining_answers = clues.filter_words(options).length
      end.max
    end
    best_worst_case = guesses_by_words_left.keys.min
    puts "Best worst case: #{best_worst_case}"
    puts "Guesses:"
    guesses = guesses_by_words_left[best_worst_case]
    if (guesses & options).length > 0
      puts (guesses & options)
    elsif (guesses & word_list.answers).length > 0
      puts (guesses & word_list.answers)
    else
      puts guesses
    end
  end
else
  STDERR.puts "usage: #{$0} WORD PATTERN [...]"
  STDERR.puts "e.g.: #{$0} wordy G.y.. words G.y.G"
  abort
end
