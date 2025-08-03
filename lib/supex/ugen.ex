defmodule Supex.Ugen do
  @moduledoc """
  For composing Oscillators and other SuperCollider's UGens (UnitGnerators).

  ## examples

      iex> import Supex.Ugen
      iex> sin() |> freq(690) |> phase(6) |> mul(0.9) |> add(0.69)
      %Supex.Ugen.SinOsc{add: 0.69, phase: 6, freq: 690, mul: 0.9}
  """
  @moduledoc since: "0.1.0"

  alias Supex.Ugen.Pan2
  alias Supex.Ugen.Pulse
  alias Supex.Ugen.Saw
  alias Supex.Ugen.SinOsc

  @type t() :: Pan2.t() | Pulse.t() | Saw.t() | SinOsc.t()

  @doc """
  Create a sine oscillator.
  """
  @doc since: "0.2.0"
  @spec sin :: SinOsc.t()
  def sin, do: %SinOsc{}

  @doc """
  Create a saw oscillator.
  """
  @doc since: "0.2.0"
  @spec saw :: Saw.t()
  def saw, do: %Saw{}

  @doc """
  Create a pulse oscillator.
  """
  @doc since: "0.2.0"
  @spec pulse :: Pulse.t()
  def pulse, do: %Pulse{}

  @doc since: "0.2.0"
  @spec pan(t()) :: Pan2.t()
  def pan(ugen), do: %Pan2{in: ugen}

  @doc since: "0.2.0"
  @spec pos(t(), integer() | float() | binary() | t()) :: Supex.Ugen.t()
  def pos(ugen, pos), do: ugen |> struct!(pos: pos)

  @doc since: "0.2.0"
  @spec level(t(), integer() | float() | binary() | t()) :: t()
  def level(ugen, level), do: ugen |> struct!(level: level)

  @doc """
  Transforms a "normal" oscillator to a LFO.

  It uses `kr` (control rate) instead of `ar`(audio rate),
  cf. https://doc.sccode.org/Tutorials/Getting-Started/05-Functions-and-Sound.html
  """
  @doc since: "0.1.0"
  @spec lfo(t()) :: t()
  def lfo(ugen), do: ugen |> struct!(lfo: true)
  # def lfo(%{lfo: _lfo} = ugen), do: ugen |> struct!(lfo: true)

  @doc since: "0.1.0"
  @spec freq(t(), integer() | float() | binary() | t()) :: t()
  def freq(ugen, freq), do: ugen |> struct!(freq: freq)

  @doc since: "0.1.0"
  @spec width(t(), integer() | float() | binary() | t()) :: t()
  def width(ugen, width), do: ugen |> struct!(width: width)

  @doc since: "0.1.0"
  @spec phase(t(), integer() | float() | binary() | t()) :: t()
  def phase(ugen, phase), do: ugen |> struct!(phase: phase)

  @doc since: "0.1.0"
  @spec mul(t(), integer() | float() | binary() | t()) :: t()
  def mul(ugen, mul), do: ugen |> struct!(mul: mul)

  @doc since: "0.1.0"
  @spec add(t(), integer() | float() | binary() | t()) :: t()
  def add(ugen, add), do: ugen |> struct!(add: add)
end
