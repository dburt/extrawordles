# Extra Wordles

A Ruby CLI Wordle clone.

To play, run `./extrawordles.rb` and follow the instructions.

## Wordle helper scripts

```ruby
require './wordle_helper'
WordleHelper.words_matching(yes: 'foo', no: 'bar')  #=> => ["coifs", "comfy", "doffs", "felon", ...]
WordleHelper.methods(false) #=> [:triplets, :greens, :best_pairs, :pairs, :words_matching, :words5, :top10, :top15, :remaining_words, :best_next_word, :most_common_characters]
```

```
% ./wordle_helper.rb ein tardloschump
["begin", "being", "binge", "eking", "eying", "feign", "genie", "genii", "given", "knife", "vixen"]
```

## To do

* Fix feedback algorithm so that multiply-guessed letters only appear yellow if there are multiples in the answer as well, e.g. {answer: ridge, guess: feeds} => ".y.y." not ".yyy."
* precalculate all guess/answer combos
* calculate information in bits like in 3brown1blue
* complete solver
* automate play by connecting solver with game
* web front end for helper
* web front end for game
