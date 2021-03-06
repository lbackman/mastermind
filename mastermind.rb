# frozen_string_literal: true

module Mastermind
  class Game
    attr_reader :current_player_id, :repeat

    def initialize(player1, player2, rounds, repeat)
      @current_player_id = 0
      @players = [player1.new(self), player2.new(self)]
      @rounds = rounds
      @repeat = repeat
      puts "#{current_player} goes first."
    end

    def start_game
      (2 * @rounds).times do
        play_round
        award_points
        current_player.turns = 0
        switch_players!
      end
      end_game
    end

    def play_round
      puts "Create a key for #{current_player} to crack"
      key = opponent.create_sequence(@repeat)
      first_guess = current_player.create_sequence(@repeat)
      current_player.guess_sequence(first_guess, key)
      if current_player.type == 'Computer'
        current_player.list = current_player.all_guesses_list
      end
    end

    def end_game
      if current_player.type == 'Computer'
        puts "Final result: Human #{opponent.points} - "\
             "#{current_player.points} Computer"
      else
        puts "Final result: Human #{current_player.points} - "\
             "#{opponent.points} Computer"
      end
    end

    def award_points
      opponent.points += current_player.turns
    end

    def other_player_id
      1 - @current_player_id
    end

    def switch_players!
      @current_player_id = other_player_id
    end

    def current_player
      @players[current_player_id]
    end

    def opponent
      @players[other_player_id]
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
  end

  class Player
    @@CHECK = [2, 2, 2, 2]
    attr_accessor :points

    def initialize(game)
      @game = game
    end
  end

  class HumanPlayer < Player
    attr_accessor :turns, :points
    attr_reader :type

    def initialize(game)
      super(game)
      @turns = 0
      @points = 0
      @type = 'Human'
    end

    def create_sequence(repeat)
      puts 'Make a sequence (four numbers from 1 - 6).'
      seq = gets.chomp.split(' ').map(&:to_i)
      if seq.size != 4
        puts 'Please, give exactly four numbers in your sequence.'
      elsif (seq.any? { |val| !(1..6).include?(val) })
        puts 'Please, only give values between 1 and 6.'
      elsif !repeat && seq.uniq != seq
        puts 'Please no duplicate values.'
      else
        return seq
      end
      create_sequence(repeat)
    end

    def guess_sequence(guess, key)
      guess_array = @game.check_guesses(guess, key)
      if guess_array == @@CHECK
        puts "#{guess_array}: You guessed correctly in #{@turns + 1} turns!"
      else
        @turns += 1
        puts "Your guess accuracy: #{guess_array}"
        new_guess = create_sequence(@game.repeat)
        guess_sequence(new_guess, key)
      end
    end

    def to_s
      'the Human Player'
    end
  end

  class ComputerPlayer < Player
    attr_accessor :turns, :points, :list
    attr_reader :type

    def initialize(game)
      super(game)
      @turns = 0
      @points = 0
      @type = 'Computer'
      @list = all_guesses_list
    end

    def create_sequence(repeat)
      options = (1..6).to_a
      result = []
      4.times do
        rand = options.sample
        result << rand
        options.delete(rand) unless repeat
      end
      # uncomment line below if needed for troubleshooting
      p result
      result
    end

    def guess_sequence(guess, key)
      puts "Guess: #{guess}"
      guess_array = @game.check_guesses(guess, key)
      if guess_array == @@CHECK
        puts "#{guess_array}: #{self} guessed correctly in #{@turns + 1} turns!"
      else
        @turns += 1
        puts "#{self}'s accuracy: #{guess_array}"
        @list.select! { |el| @game.check_guesses(guess, el) == guess_array }
        @list.delete(guess)
        # sleep 2
        guess_sequence(@list.sample, key)
      end
    end

    def all_guesses_list
      add_one_to_el.map { |n| num_to_arr(n) }
    end

    def add_one_to_el
      a = base_6_array
      a.map(&:to_i).map { |el| el + 1111 }.map(&:to_s)
    end

    def base_6_array
      a = (0..1295).to_a.map { |num| num.to_s(6) }
      a.map { |el| el.prepend('0') while el.length < 4 }
      a
    end

    def num_to_arr(num)
      num.to_s.split('').map(&:to_i)
    end

    def to_s
      "Computer #{@game.current_player_id}"
    end
  end
end

include Mastermind

def start_playing
  rounds = choose_rounds
  order = choose_order
  repeat = include_repeat?
  Game.new(*order, rounds, repeat).start_game
end

def include_repeat?
  puts 'Do you want to include repeats in your codes? (y/n)'
  input = gets.chomp
  return true if input == 'y'

  false
end

def choose_order
  puts 'Do you want to start as the setter or as the guesser? (s/g)'
  input = gets.chomp
  return [HumanPlayer, ComputerPlayer] if input == 'g'
  return [ComputerPlayer, HumanPlayer] if input == 's'

  puts 'Invalid input'
  choose_order
end

def choose_rounds
  puts 'How many rounds do you want to play? (1-5)'
  input = gets.to_i
  return input if (1..5).include?(input)

  puts "That's an invalid choice, please try again"
  choose_rounds
end

start_playing

# players_with_human = [HumanPlayer, ComputerPlayer].shuffle
# Game.new(*players_with_human, 2, true).start_game
