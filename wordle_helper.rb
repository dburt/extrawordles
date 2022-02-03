#!/usr/bin/ruby

module WordleHelper
  class << self

    def words
      #@words ||= %w(wordlist validGuesses).sum([]) {|list| File.readlines("#{list}.txt") }.map(&:chomp)
      # File.readlines('wordlist.txt').map(&:chomp)
      return File.readlines('gnt-words.txt').map(&:chomp)

      # words = File.readlines('/usr/share/dict/words')
      # # words.count
      # words = words.map(&:chomp).grep(/^[a-z]{5}$/)
      # # words.length #=> 4594
    end

    def most_common_characters(n = nil)
      words.inject([]) {|chars, word| chars + word.chars.uniq }.tally.sort_by {|c, n| n }.reverse
      # words.join.chars.tally
      # # _.sort_by {|c, n| n }
      # # _.reverse[0, 15]
      # # _.map {|c, n| [c, n / 6806.0] }
      # # _.map(&:first).join #=> "searolitnducpmh"
      # words.grep(/s/).grep(/e/).grep(/a/).grep(/o/).grep(/r/)  #=> ["arose"]
    end

    def top10
      top10chars = most_common_characters[0, 12].map(&:first)
      words.map(&:chomp).select {|word| word !~ /[^#{top10chars.join}]/ }
    end # top10.count #=> 465

    def pairs
      @pairs ||= begin
        pairs = []
        top10.each do |w1|
          top10.each do |w2|
            pairs << [w1, w2] if w1 < w2 && (w1 + w2).chars.uniq.length == 10
          end
        end
        pairs
      end
      # pairs.count #=> 88
    end
    #pairs.map {|a| a.join " " } #=> ["adorn islet", "adorn stile", "adorn tiles", "ailed snort", "altos diner", "anted roils", "antis older", "arson tilde", "arson tiled", "astir olden", "dealt irons", "dealt rosin", "delta irons", "delta rosin", "dials tenor", "dials toner", "doles train", "drain stole", "dries talon", "dries tonal", "drone tails", "enrol staid", "ideal snort", "inert loads", "inlet roads", "inter loads", "islet radon", "laden riots", "laden tiros", "laden torsi", "laden trios", "lairs noted", "lairs toned", "lends ratio", "liars noted", "liars toned", "lined roast", "lined sorta", "lined taros", "liner toads", "lions rated", "lions tared", "lions trade", "lions tread", "liras noted", "liras toned", "loads niter", "loans tired", "loans tried", "lodes train", "loins rated", "loins tared", "loins trade", "loins tread", "loner staid", "nadir stole", "nodal rites", "nodal tiers", "nodal tires", "nodal tries", "nodes trail", "nodes trial", "noels triad", "nosed trail", "nosed trial", "noted rails", "oiled rants", "olden sitar", "olden stair", "older saint", "older satin", "older stain", "oldie rants", "radon stile", "radon tiles", "rails toned", "rides talon", "rides tonal", "roans tilde", "roans tiled", "salon tired", "salon tried", "sired talon", "sired tonal", "snore tidal", "soled train", "sonar tilde", "sonar tiled"]

    def top15
      @top15 ||= words.map(&:chomp).select {|word| word !~ /[^seaoriltnducypm]/ }
      # top15.count  #=> 1735
    end
    def triplets
      triplets = [];
      top15.each {|w1|
        top15.each {|w2| next unless w1 < w2 && (w1 + w2).chars.uniq.length == 10
        top15.each {|w3| 
        triplets << [w1, w2, w3] if w1 < w2 && w2 < w3 && (w1 + w2 + w3).chars.uniq.length == 15 }}}; triplets.count
    end
    #=> 1953

    # # next5 = words.map(&:chomp).select {|word| word !~ /[^ucypmhj]/ }; next5.count
    # # # => ["chump", "jumpy", "mummy", "puppy", "yummy", "yuppy"]

    def greens(w1, w2)
      (w1 ^ w2).scan(/\u0000/).count
    end

    def best_pairs
      pairs.
        map {|w1, w2| [w1, w2, words.sum{|w3| greens(w1, w3) + greens(w2, w3) }] }.
        sort_by {|w1, w2, greens| greens }.reverse[0, 10]
      #=> [["loins", "tared", 6007], ["rails", "toned", 5955], ["lairs", "toned", 5889], ["loans", "tired", 5850], ["lions", "tared", 5799], ["roans", "tiled", 5795], ["loans", "tried", 5775], ["loins", "rated", 5756], ["liars", "toned", 5732], ["dials", "toner", 5712]]
    end

    def words_matching(yes: [], no: [])
      y = yes.respond_to?(:chars) ? yes.chars : yes
      n = no.respond_to?(:chars) ? no.chars : no
      words.select do |word|
        y.all? {|c| word.include?(c) } &&
        n.none? {|c| word.include?(c) }
      end
    end

    def remaining_words(guesses: [], colours: [])
      words.select do |word|
        guesses.zip(colours).all? do |guess, cols|
          guess.chars.zip(cols).each_with_index.all? do |(c, col), i|
            case col
            when :green
              word[i] == c
            when :yellow
              word[i] != c && word.include?(c)
            else
              true
            end
          end
        end
      end
    end

    # def yes_no_from_colours(words_guessed: [], colours: [])
    # def tally_remaining_words -- given each word guessed / given each word is answer / response --> 

    def best_next_word(words_guessed: [], colours: [])
      raise NotImplementedError
    end

    # new functions:
      # WordList
        # pick_word: (wordlist) => (answer)
        # in_list: (wordlist, guess) => (bool)
      # WordleClues
        # guess: (answer, guess) => (pattern)
          # guess_to_clues: (answer, guess) => (clues)
          # clues_to_pattern: (guess, clues) => (pattern)
        # learn: (clues, pattern) => (clues)
          # pattern_to_clues: (pattern) => (clues)
        # filter: (wordlist, clues) => (shortlist)
  end
end

class String
  def ^( other )  # by Phrogz: https://stackoverflow.com/a/6099613/1279840
    b1 = self.unpack("U*")
    b2 = other.unpack("U*")
    longest = [b1.length, b2.length].max
    b1 = [0] * (longest - b1.length) + b1
    b2 = [0] * (longest - b2.length) + b2
    b1.zip(b2).map{ |a, b| a ^ b }.pack("U*")
  end
end

if __FILE__ == $0
  p WordleHelper.words_matching yes: ARGV[0], no: ARGV[1]
end
