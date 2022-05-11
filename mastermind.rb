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

def check_exact(guess, key)
  final = []
  i = 0
  while i < guess.size
    if key[i] == guess[i]
      final << 2
      key.delete_at(i)
      guess.delete_at(i)
    else
      i += 1
    end
  end
  final
end

def check_inexact(guess, key, final)
  guess.each_index do |i|
    if key.include?(guess[-(i + 1)])
      final << 1
      key.delete_at(key.index(guess[-(i + 1)]))
    end
  end
  final
end

def append_zeros(final)
  (4 - final.size).times { final << 0 }
  final
end

def check_guesses(guess, key)
  temp_guess = guess[0, 4]
  temp_key = key[0, 4]
  partial = check_exact(temp_guess, temp_key)
  final = check_inexact(temp_guess, temp_key, partial)
  append_zeros(final)
end
