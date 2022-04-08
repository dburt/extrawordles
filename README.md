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
% ./helper2.rb tired .yy.G
grind
rabid
braid
druid
rapid
Finding best guess to differentiate...
Best worst case: 1
Guesses:
braid
rabid
rapid
```

## To do

* fix clues to include information about multiply-matched letters
* calculate information in bits like in 3brown1blue
* find best fixed 2-, 3-, 4- and 5-word guesses
* complete solver
* automate play by connecting solver with game
* web front end for helper
* web front end for game
