# frozen_string_literal: true

# This module contains all mastermind methods
module Mastermind
  def create_array(repeat = false)
    options = (1..6).to_a
    result = []
    4.times do
      rand = options.sample
      result << rand
      options.delete(rand) unless repeat
    end
    result
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

  def make_sequence
    puts 'Make a sequence (four numbers from 1 - 6).'
    guess = gets.chomp.split(' ').map(&:to_i)
    if guess.size == 4
      if guess.all? { |val| (1..6).include?(val) }
        guess
      else
        puts 'Please, only give values between 1 and 6.'
        make_sequence
      end
    else
      puts 'Please, give exactly four numbers in your sequence.'
      make_sequence
    end
  end

  def all_guesses_list
    final = add_one_to_el.map { |n| num_to_arr(n) }
    final
  end

  def add_one_to_el
    a = (0..1295).to_a.map { |num| num.to_s(6) }
    a.map { |el| el.prepend('0') while el.length < 4 }
    a
  end

  def base_6_array
    a = (0..1295).to_a.map { |num| num.to_s(6)}
    new_a = a.map do |el|
      while el.length < 4
        el.prepend('0')
      end
    end
    a
  end

  def num_to_arr(num)
    num.to_s.split('').map(&:to_i)
  end
end

# This class makes players
class Player
  attr_reader :role

  def initialize(role)
    @role = role
  end
end

# Instantiates a new game
class Game
  include Mastermind

  @@CHECK = [2, 2, 2, 2]

  def initialize(player1, player2, repeat = false)
    @player1 = player1
    @player2 = player2
    @repeat = repeat
  end

  def start_game
    if @player1.role == 'guesser'
      @key = self.create_array(@repeat)
      puts "Answer key: #{@key}"
      start_guessing
    else
      @list = self.all_guesses_list
      @key = self.make_sequence
      @turns = 0
      guessing_algorithm(@list.sample, @key)
    end
  end

  # private

  def start_guessing
    @guess = self.make_sequence
    guess_array = check_guesses(@guess, @key)
    if guess_array == @@CHECK
      puts "#{guess_array}: Congrats, you won!"
    else
      puts "Your guess accuracy: #{guess_array}"
      start_guessing
    end
  end

  def guessing_algorithm(guess, key)
    puts "Guess: #{guess}"
    guess_array = check_guesses(guess, key)
    if guess_array == @@CHECK
      puts "#{guess_array}: Computer wins in #{@turns + 1} rounds!"
    else
      @turns += 1
      puts "Computer's accuracy: #{guess_array}"
      @list = @list.select { |el| check_guesses(guess, el) == guess_array }
      @list.delete(guess)
      sleep 2
      guessing_algorithm(@list.sample, key)
    end
  end
end

# TODO: 
# - give player ability to choose between setting and guessing
# - implement points and rounds

p1 = Player.new('setter')
p2 = Player.new('guesser')
mm = Game.new(p1, p2, true)
mm.start_game