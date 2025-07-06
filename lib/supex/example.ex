defmodule Supex.Example do
  @moduledoc """
  Examples for using Supex.

  You can play these examples with `Supex.play()`, e.g.

     Supex.Example.pulse_wave_modulation_with_lfo() |> Supex.play()

  Stop all playing sounds with `Supex.stop_playing()`.
  """
  import Supex

  @doc since: "0.1.0"
  @spec pulse_wave_modulation_with_lfo() :: none()
  def pulse_wave_modulation_with_lfo() do
    osc(:pulse)
    |> mul(
      osc()
      |> freq(2)
      |> mul(0.4)
      |> add(0.5)
      |> lfo
    )
    |> freq(
      osc(:saw)
      |> freq(0.1)
      |> mul(100)
      |> add(100)
      |> lfo
    )
    |> width(
      osc()
      |> freq(6)
      |> mul(0.5)
      |> add(0.5)
      |> lfo
    )
  end
end
