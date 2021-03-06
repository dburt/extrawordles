#!/usr/bin/ruby

require 'set'
require 'json'
require 'rubygems'
require 'paint'

require_relative './word_list'

WORD_LENGTH = 5
MAX_GUESSES = 6
LOG_FILE = "extrawordles_log.json"

# word_list = WordList.new(answers_file: '/usr/share/dict/words', word_length: WORD_LENGTH)
word_list = WordList.new(answers_file: 'wordlist.txt', guesses_file: 'validGuesses.txt', word_length: WORD_LENGTH)

target_word = word_list.pick_word
guess_word = nil
guesses = []
letter_colours = ('a'..'z').map {|c| [c, :black] }.to_h

colour = ->(c, i) {
  if target_word[i] == c
    :green
  elsif target_word.chars.include?(c)
    :yellow
  else
    :white
  end
}

puts "Guess the #{WORD_LENGTH}-letter word."
t0 = Time.now

while guesses.count < MAX_GUESSES && guess_word != target_word
  puts "You have #{MAX_GUESSES - guesses.count} guesses remaining."
  guess_word = gets.chomp

  while !word_list.in_list?(guess_word)
    puts "That's not a #{WORD_LENGTH}-letter word in our dictionary."
    guess_word = gets.chomp
  end

  guesses << guess_word

  print "\033[F"  # ANSI - beginning of previous line

  guess_word.chars.each_with_index do |c, i|
    col = colour[c, i]
    print Paint[c, col, :bright]
    letter_colours[c] = col
  end
  puts

  ('a'..'z').each do |c|
    print Paint[c, letter_colours[c], :bright]
  end
  puts
end

win = guess_word == target_word
if win
  puts "Well done, got it in #{guesses.count}"
else
  puts "Better luck next time, the word was: ", target_word
end

log = JSON.load_file(LOG_FILE) # rescue nil
log ||= []
log << {'t' => Time.now, 'word' => target_word, 'win' => win, 'guesses' => guesses.count, 't0' => t0}
File.open(LOG_FILE, "w") {|f| f.puts JSON.dump(log) }

attempts = log.length
wins = log.select {|entry| entry['win'] }.length
streaks = log.map {|entry| entry['win'] ? 'X' : '.' }.join
current_streak = streaks[/X*$/].length
max_streak = streaks.scan(/X*/).sort.last.length
guesses_tally = log.map {|entry| entry['guesses'] }.tally

puts "#{attempts} \tPlayed"
puts "#{(wins / attempts.to_f * 100).round} \tWin %"
puts "#{current_streak} \tCurrent Streak"
puts "#{max_streak} \tMax Streak"
(1..6).each do |n|
  freq = guesses_tally[n].to_i
  puts "#{n}: #{ '#' * freq }  #{freq}"
end
