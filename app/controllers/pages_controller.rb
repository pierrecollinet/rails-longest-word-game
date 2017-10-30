require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    @grid = generate_grid(9)
  end

  def score
    start_time = Time.now
    @attempt = params[:guess]
    end_time = Time.now
    grid = params[:grid]
    @result = run_game(@attempt, grid, start_time, end_time)

  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    array_letters = []
    grid_size.times do
      array_letters << ('A'..'Z').to_a[rand(26)]
    end
    return array_letters
  end

  def run_game(attempt, grid, start_time, end_time)
    if session[:total_games]
      session[:total_games] += 1
    else
      session[:total_games] = 1
    end

    url = 'https://wagon-dictionary.herokuapp.com/' + attempt.to_s
    resultat_serialized = open(url).read
    resultat = JSON.parse(resultat_serialized)
    result = {}
    if resultat['found'] && mycontains?(attempt, grid)
      result[:time] = end_time - start_time
      result[:score] = attempt.size * (10.0 / result[:time])
      result[:message] = "Well Done!"
    elsif !mycontains?(attempt, grid)
      result[:score] = 0
      result[:message] = "not in the grid"
    else
      result[:score] = 0
      result[:message] = "not an english word"
    end
    result[:time] = end_time - start_time
    result[:total_games] = session[:total_games]

    if session[:total_score]
      session[:total_score] += result[:score]
    else
      session[:total_score] = result[:score]
    end
    result[:total_score] = session[:total_score]
    result[:average] = session[:total_score].to_i / session[:total_games].to_i
    return result
    # TODO: runs the game and return detailed hash of result
  end

  def mycontains?(attempt, grid)
    result = true
    newgrid = grid.downcase.chars
    attempt.downcase.chars.each.each do |variable|
      if newgrid.join('').downcase.chars.include?(variable)
        newgrid.find { newgrid.delete_at(newgrid.index(variable)) }
      else
        return false
      end
    end
    return result
  end


end
