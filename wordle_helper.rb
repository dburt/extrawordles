#!/usr/bin/ruby

module WordleHelper
  class << self

    def words5
      words = File.readlines('/usr/share/dict/words')
      # words.count
      words5 = words.map(&:chomp).grep(/^[a-z]{5}$/)
      # words5.length #=> 4594
    end
    # words5.join.chars.tally
    # # _.sort_by {|c, n| n }
    # # _.reverse[0, 15]
    # # _.map {|c, n| [c, n / 6806.0] }
    # # _.map(&:first).join #=> "searolitnducpmh"
    # words5.grep(/s/).grep(/e/).grep(/a/).grep(/o/).grep(/r/)  #=> ["arose"]

    def top10
      words5.map(&:chomp).select {|word| word !~ /[^seaoriltnd]/ }
    end # top10.count #=> 465

    def pairs
      @pairs ||= begin
        pairs = []
        top10.each do |w1|
          top10.each do |w2|
            pairs << [w1, w2] if w1 < w2 && (w1 + w2).chars.uniq.length == 10
          end
        end
      end
      # pairs.count #=> 88
    end
    #pairs.map {|a| a.join " " } #=> ["adorn islet", "adorn stile", "adorn tiles", "ailed snort", "altos diner", "anted roils", "antis older", "arson tilde", "arson tiled", "astir olden", "dealt irons", "dealt rosin", "delta irons", "delta rosin", "dials tenor", "dials toner", "doles train", "drain stole", "dries talon", "dries tonal", "drone tails", "enrol staid", "ideal snort", "inert loads", "inlet roads", "inter loads", "islet radon", "laden riots", "laden tiros", "laden torsi", "laden trios", "lairs noted", "lairs toned", "lends ratio", "liars noted", "liars toned", "lined roast", "lined sorta", "lined taros", "liner toads", "lions rated", "lions tared", "lions trade", "lions tread", "liras noted", "liras toned", "loads niter", "loans tired", "loans tried", "lodes train", "loins rated", "loins tared", "loins trade", "loins tread", "loner staid", "nadir stole", "nodal rites", "nodal tiers", "nodal tires", "nodal tries", "nodes trail", "nodes trial", "noels triad", "nosed trail", "nosed trial", "noted rails", "oiled rants", "olden sitar", "olden stair", "older saint", "older satin", "older stain", "oldie rants", "radon stile", "radon tiles", "rails toned", "rides talon", "rides tonal", "roans tilde", "roans tiled", "salon tired", "salon tried", "sired talon", "sired tonal", "snore tidal", "soled train", "sonar tilde", "sonar tiled"]

    def top15
      @top15 ||= words5.map(&:chomp).select {|word| word !~ /[^seaoriltnducypm]/ }
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

    # # next5 = words5.map(&:chomp).select {|word| word !~ /[^ucypmhj]/ }; next5.count
    # # # => ["chump", "jumpy", "mummy", "puppy", "yummy", "yuppy"]

    def greens(w1, w2)
      (w1 ^ w2).scan(/\u0000/).count
    end

    def best_pairs
      pairs.
        map {|w1, w2| [w1, w2, words5.sum{|w3| greens(w1, w3) + greens(w2, w3) }] }.
        sort_by {|w1, w2, greens| greens }.reverse[0, 10]
      #=> [["loins", "tared", 6007], ["rails", "toned", 5955], ["lairs", "toned", 5889], ["loans", "tired", 5850], ["lions", "tared", 5799], ["roans", "tiled", 5795], ["loans", "tried", 5775], ["loins", "rated", 5756], ["liars", "toned", 5732], ["dials", "toner", 5712]]
    end

    def words_matching(yes: [], no: [])
      y = yes.respond_to?(:chars) ? yes.chars : yes
      n = no.respond_to?(:chars) ? no.chars : no
      words5.select do |word|
        y.all? {|c| word.include?(c) } &&
        n.none? {|c| word.include?(c) }
      end
    end
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