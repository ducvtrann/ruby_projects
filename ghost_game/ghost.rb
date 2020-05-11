# frozen_string_literal: false

require 'set'
require_relative 'player'
# Ghost Game
class GhostGame
  ALPHABET = Set.new('a'..'z')
  MAX_LOSS_COUNT = 5

  attr_reader :fragment, :dictionary, :losses, :players

  def initialize(*players)
    words = File.readlines('dictionary.txt').map(&:chomp)
    @dictionary = Set.new(words)
    @players = players
    @losses = Hash.new { |losses, player| losses[player] = 0 }
  end

  def run
    load_players_score_card
    play_round until game_over?
    puts "#{winner} wins!"
  end

  private

  def load_players_score_card
    players.each do |player|
      losses[player]
    end
  end

  def play_round
    @fragment = ''
    welcome

    until round_over?
      take_turn
      next_player!
    end

    update_standings
  end

  def welcome
    system('clear')
    puts "Let's play a round of Ghost!"
    display_standings
  end

  def display_standings
    puts 'Current Standing: '

    players.each do |player|
      puts "#{player}: #{record(player)}"
    end

    sleep(2)
  end

  def record(player)
    count = losses[player]
    'GHOST'.slice(0, count)
  end

  def round_over?
    dictionary.include?(fragment)
  end

  def take_turn
    system('clear')
    puts "It's #{current_player}'s turn!"
    letter = nil

    until letter
      letter = current_player.guess(fragment)

      unless valid_play?(letter)
        current_player.alert_invalid_move(letter)
        letter = nil
      end
    end

    add_letter(letter)
    puts "#{current_player} added the letter '#{letter}' to the fragment."
  end

  def valid_play?(letter)
    return false unless ALPHABET.include?(letter)

    potential_fragment = fragment + letter
    dictionary.any? { |word| word.start_with?(potential_fragment) }
  end

  def add_letter(letter)
    fragment << letter
  end

  def update_standings
    system('clear')
    puts "#{previous_player} spelled #{fragment}."
    puts "#{previous_player} gets a letter!"
    sleep(1)

    if losses[previous_player] == MAX_LOSS_COUNT - 1
      puts "#{previous_player} has been eliminated!"
      sleep(1)
    end

    losses[previous_player] += 1

    display_standings
  end

  def game_over?
    remaining_players == 1
  end

  def remaining_players
    losses.count { |_key, value| value < MAX_LOSS_COUNT }
  end

  def current_player
    players.first
  end

  def next_player!
    players.rotate!
    players.rotate! until losses[current_player] < MAX_LOSS_COUNT
  end

  def winner
    (player,) = losses.find { |_, losses| losses < MAX_LOSS_COUNT }
    player
  end

  def previous_player
    (players.count - 1).downto(0).each do |idx|
      player = players[idx]

      return player if losses[player] < MAX_LOSS_COUNT
    end
  end
end

if $PROGRAM_NAME == __FILE__
  # Add more players here
  game = GhostGame.new(
    Player.new('John'),
    Player.new('Mike'),
    Player.new('Christy'),
    Player.new('Selena')
  )
  game.run
end
