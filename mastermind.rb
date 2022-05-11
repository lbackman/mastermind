# frozen_string_literal: true

module Mastermind
  # Method For randomly generating sequences
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

  # Methods For checking guesses when there *ARE* repeats
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
      if key.include?(guess[i])
        final << 1
        key.delete_at(key.index(guess[i]))
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
end

class Player
  def initialize(role)
    @role = role
  end
end
