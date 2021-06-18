defmodule PointingPoker.Player do
  alias PointingPoker.Player
  alias PointingPoker.Util

  # sum type
  # state: :observer |
  #  {:participant, :not_voted} |
  #  {:participant, {:voted, vote}} |
  #  {:participant, :abstain}

  defstruct [:id, :name, :state, :disconnected_at]

  def new(id, name, observer \\ false) do
    if observer do
      %Player{id: id, name: name, state: :observer}
    else
      %Player{id: id, name: name, state: {:participant, :not_voted}}
    end
  end

  def vote(player, vote) when is_number(vote) do
    if player.state == :observer do
      player
    else
      %Player{player | state: {:participant, {:voted, vote}}}
    end
  end

  def vote(player, "?") do
    if player.state == :observer do
      player
    else
      %Player{player | state: {:participant, :abstain}}
    end
  end

  def clear_vote(player) do
    if player.state == :observer do
      player
    else
      %Player{player | state: {:participant, :not_voted}}
    end
  end

  def eligible_to_vote(%Player{state: {:participant, _}} = player) do
    true
  end

  def eligible_to_vote(_player) do
    false
  end

  def voted?(%Player{state: {:participant, :abstain}} = player) do
    true
  end

  def voted?(%Player{state: {:participant, {:voted, _}}} = player) do
    true
  end

  def voted?(player) do
    false
  end

  def get_numerical_vote(%Player{state: {:participant, {:voted, vote}}} = player) do
    vote
  end

  def get_numerical_vote(_player) do
    nil
  end

  def get_formatted_vote(%Player{state: {:participant, :abstain}} = player) do
    "?"
  end

  def get_formatted_vote(%Player{state: {:participant, {:voted, vote}}} = player) do
    round(vote)
  end

  def get_formatted_vote(player) do
    nil
  end
end
