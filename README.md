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
