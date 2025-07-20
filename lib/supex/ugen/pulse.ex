defmodule Supex.Ugen.Pulse do
  @moduledoc """
  Module for the SuperCollider Pulse wave generator,
  see https://doc.sccode.org/Classes/Pulse.html

  Defines a `%Pulse{}` struct with

  `freq` frequency in Hertz,

  `width` pulse width ratio from zero to one (0.5 makes a square wave)

  `mul` output will be multiplied by this value,

  `add` this value will be added to the output.
  """
  @moduledoc since: "0.2.0"

  defstruct freq: 440, width: 0.5, mul: 0.2, add: 0, lfo: false

  @doc """
  Builds the SuperCollider command from the `%Pulse{}` struct.

  ## example

      iex> alias Supex.Ugen.Pulse
      iex> %Pulse{freq: 440, width: 0, mul: 0.1, add: 0, lfo: false} |> Pulse.command()
      "Pulse.ar(freq: 440, width: 0, mul: 0.1, add: 0);"

      iex> alias Supex.Ugen.Pulse
      iex> %Pulse{freq: 440, width: 0, mul: 0.1, add: 0, lfo: true} |> Pulse.command()
      "Pulse.kr(freq: 440, width: 0, mul: 0.1, add: 0);"
  """
  @doc since: "0.2.0"
  @spec command(struct()) :: binary()
  def command(%__MODULE__{} = pulse) do
    %__MODULE__{freq: freq, width: width, mul: mul, add: add, lfo: lfo} = pulse
    "Pulse.ar(freq: #{freq}, width: #{width}, mul: #{mul}, add: #{add});" |> check_lfo(lfo)
  end

  # `kr` (control rate) instead of `ar`(audio rate) for LFO usage
  defp check_lfo(sc_command, lfo) when lfo, do: sc_command |> String.replace("ar(", "kr(")
  defp check_lfo(sc_command, _lfo), do: sc_command
end
