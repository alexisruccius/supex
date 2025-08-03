defmodule Supex.Ugen.Saw do
  @moduledoc """
  Module for the SuperCollider Saw wave generator,
  see https://doc.sccode.org/Classes/Saw.html

  Defines a `%Saw{}` struct with

  `freq:` frequency in Hertz,

  `mul` output will be multiplied by this value,

  `add` this value will be added to the output.

  """
  @moduledoc since: "0.2.0"

  @type t() :: %__MODULE__{freq: number(), mul: number(), add: number(), lfo: boolean()}
  defstruct freq: 440, mul: 0.1, add: 0, lfo: false

  @doc """
  Builds the SuperCollider command from the `%Saw{}` struct.

  ## example

      iex> alias Supex.Ugen.Saw
      iex> %Saw{freq: 440, mul: 0.1, add: 0, lfo: false} |> Saw.command()
      "Saw.ar(freq: 440, mul: 0.1, add: 0);"

      iex> alias Supex.Ugen.Saw
      iex> %Saw{freq: 440, mul: 0.1, add: 0, lfo: true} |> Saw.command()
      "Saw.kr(freq: 440, mul: 0.1, add: 0);"
  """
  @doc since: "0.2.0"
  @spec command(t()) :: binary()
  def command(%__MODULE__{} = saw) do
    %__MODULE__{freq: freq, mul: mul, add: add, lfo: lfo} = saw
    "Saw.ar(freq: #{freq}, mul: #{mul}, add: #{add});" |> check_lfo(lfo)
  end

  # `kr` (control rate) instead of `ar`(audio rate) for LFO usage
  defp check_lfo(sc_command, lfo) when lfo, do: sc_command |> String.replace("ar(", "kr(")
  defp check_lfo(sc_command, _lfo), do: sc_command
end
