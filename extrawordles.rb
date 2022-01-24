#!/usr/bin/ruby

require 'rubygems'
require 'paint'
require 'set'

MAX_GUESSES = 6
words = File.readlines('/usr/share/dict/words'); words.count
words5 = words.map(&:chomp).grep(/^[a-z]{5}$/); words5.length

target_word = words5.sample
guesses_remaining = MAX_GUESSES
guess_word = nil
guessed = Set.new
colour = ->(c, i, target_word) {
  if target_word[i] == c
    :green
  elsif target_word.chars.include?(c)
    :yellow
  elsif guessed.include?(c)
    :white
  else
    :black
  end
}

puts "Guess the 5-letter word."

while guesses_remaining > 0 && guess_word != target_word
  puts "You have #{guesses_remaining} guesses remaining."
  guess_word = gets.chomp

  while !words5.include? guess_word
    puts "That's not a 5-letter word in our dictionary."
    guess_word = gets.chomp
  end

  print "\033[F"  # ANSI - beginning of previous line

  guess_word.chars.each_with_index do |c, i|
    guessed << c
    print Paint[c, colour[c, i, target_word], :bright]
  end
  puts

  ('a'..'z').each_with_index do |c, i|
    print Paint[c, colour[c, i, target_word], :bright]
  end
  puts

  guesses_remaining -= 1
end

if guess_word == target_word
  puts "Well done, got it in #{MAX_GUESSES - guesses_remaining}"
else
  puts "Better luck next time, the word was: ", target_word
end
