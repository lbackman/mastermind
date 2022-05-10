# frozen_string_literal: true

# Methods for randomly generating sequences
def create_array(repeat: false)
  options = (1..6).to_a
  result = []
  4.times do
    rand = options.sample
    result << rand
    options.delete(rand) unless repeat
  end
  result
end

def guess_accuracy(guess, key)
  guess.each_index.map do |i|
    if key[i] == guess[i]
      2
    elsif key.include?(guess[i])
      1
    else
      0
    end
  end
end

def sorted_guesses(guess, key)
  guess_accuracy(guess, key).sort.reverse
end