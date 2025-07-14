defmodule Supex do
  @moduledoc """
  Supex = SuperCollider + Elixir

  An Elixir wrapper for the music live-coding language SuperCollider.
  Supex communicates with SuperCollider's `sclang` tool, letting you generate and control sound directly from Elixir.

  - 🎧 Play basic oscillators with a clean, pipeable syntax
  - 🔤 Send raw SuperCollider code when needed
  - ⛔ Stop sounds by name

  Built for musicians, coders, and live performers who want to use Elixir for audio synthesis.

  👉 Requires `sclang` installed (`sudo apt install sclang` on Linux)


  ## Installation

  The package can be installed by adding `supex` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
  [
    {:supex, "~> 0.1.0"}
  ]
  end
  ```

  ## 🔍 Learn SuperCollider basics

  https://doc.sccode.org/Tutorials/Getting-Started/00-Getting-Started-With-SC.html

  ## ⚙️ Requirements:
  SuperCollider's `sclang` must be installed.
  Example (Linux): `sudo apt install sclang`

  ## 🟢 Start the SuperCollider sclang server

  ```elixir
  iex> Supex.Sclang.start_link(:ok)
  ```

  ## 💡 Examples

  ▶ Play a sine oscillator at 269 Hz and name it "y", pan to center; then stop it:

  ```elixir
  iex> import Supex
  iex> sin |> freq(269) |> pan |> play("y")
  iex> stop("y")
  # or stop all
  iex> stop
  ```

  ▶ Modulate volume of a sine wave using another sine as LFO:

  ```elixir
  iex> import Supex
  iex> sin |> mul(sin |> freq(2) |> mul(0.4) |> add(0.5) |> lfo) |> pan |> play
  iex> sin |> stop
  # or stop all
  iex> stop
  ```

  ▶ Modulate a pulse wave's frequency and width:

  ```elixir
  iex> import Supex
  iex> pulse |> freq(saw |> freq(0.1) |> mul(100) |> add(100) |> lfo) |> width(sin |> freq(6) |> mul(0.5) |> add(0.5) |> lfo) |> pan |> play
  iex> stop("x")
  # or stop all
  iex> stop
  ```

  🔤 Send a raw SuperCollider expression:

  ```elixir
  iex> import Supex
  iex> "RLPF.ar(Pulse.ar([100, 250], 0.5, 0.1), XLine.kr(8000, 400, 5), 0.05)" |> pan |> play
  iex> stop("x")
  # or stop all
  iex> stop
  ```

  ## ⚠️ Disclaimer

  SuperCollider and Supex can produce loud, sudden sounds.
  Use volume control and a limiter to protect your ears.
  Avoid hearing damage.

  ## 🛠️ Note

  Supex is in early development.
  Expect API changes.
  """

  alias Supex.Command
  alias Supex.Synth
  alias Supex.Sclang
  alias Supex.Ugen

  @doc """
  Create an oscillator.
  `type` can be:

    `:sin` (sinus wave)
    `:saw` (saw wave)
    `:pulse` (pulse wave, aka square wave)

  Defaults to `:sin`.
  """
  @deprecated "Use Supex.sin/0 instead"
  @doc since: "0.1.0"
  @spec osc() :: struct()
  def osc(), do: Ugen.sin()

  @deprecated "Use Supex.sin/0, Supex.saw/0, or Supex.pulse/0 instead"
  @doc since: "0.1.0"
  @spec osc(atom()) :: struct()
  def osc(:sin), do: Ugen.sin()
  def osc(:saw), do: Ugen.saw()
  def osc(:pulse), do: Ugen.pulse()

  @doc """
  Create a sine oscillator.
  """
  @doc since: "0.2.0"
  def sin(), do: Ugen.sin()

  @doc """
  Create a saw oscillator.
  """
  @doc since: "0.2.0"
  def saw(), do: Ugen.saw()

  @doc """
  Create a pulse oscillator.
  """
  @doc since: "0.2.0"
  def pulse(), do: Ugen.pulse()

  @doc """
  Transforms a "normal" oscillator to a LFO to use it as a modulator.

  It uses `kr` (control rate) instead of `ar`(audio rate),
  cf. https://doc.sccode.org/Tutorials/Getting-Started/05-Functions-and-Sound.html

  ## example

  Modulate the volume of a sine wave with another sine wave as an LFO:

  ```elixir
  iex> import Supex
  iex> sin |> mul(osc |> freq(3) |> mul(0.5) |> add(0.5) |> lfo) |> pan |> play
  iex> stop
  ```

    or

  ```elixir
  iex> pulse |> mul(sin |> freq(2) |> mul(0.4) |> add(0.5) |> lfo) |> freq(saw |> freq(0.2) |> mul(100) |> add(100) |> lfo) |> pan |> play
  ```
  """
  @doc since: "0.1.0"
  @spec lfo(struct()) :: struct()
  defdelegate lfo(ugen), to: Ugen

  @doc """
  Tune the frequency of an oscillator.

  `freq` can be an integer or float.
  """
  @doc since: "0.1.0"
  @spec freq(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate freq(ugen, freq), to: Ugen

  @doc """
  The pulse width of a pulse wave oscillator.

  `width` should be a value between `0.01` and `0.99`.
  """
  @doc since: "0.1.0"
  @spec width(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate width(ugen, width), to: Ugen

  @doc """
  The phase of a sinus wave.
  """
  @doc since: "0.1.0"
  @spec phase(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate phase(ugen, phase), to: Ugen

  @doc """
  Multiplication of the signal.

  Choose values between `0.1` and `1` for not hurting your ears.
  """
  @doc since: "0.1.0"
  @spec mul(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate mul(ugen, mul), to: Ugen

  @doc """
  Add the value to the signal.

  Values can be `0.1` or `1` for example.
  """
  @doc since: "0.1.0"
  @spec add(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate add(ugen, add), to: Ugen

  @doc """
  A synth definition.
  """
  @doc since: "0.1.0"
  @spec synth(binary()) :: binary()
  defdelegate synth(name), to: Synth, as: :define

  @doc """
  Pans the mono signal in the stereo spectrum.

  Defaults to centering the signal.

  Use `pos/2` for panning the position (-1.0 = left, 0 = center, 1.0 = right).

  Use `level/2` for scaling the output level.

  ## example

  iex> sin |> freq(269) |> pan |> pos(0.69) |> play
  """
  @doc since: "0.2.0"
  @spec pan(struct()) :: struct()
  defdelegate pan(ugen), to: Ugen

  @doc """
  Pan position -1.0 = left, 0 = center, 1.0 = right

  ## example

  Pan a sound slightly to the right:

      iex> sin |> freq(269) |> pan |> pos(0.69) |> play
  """
  @doc since: "0.2.0"
  @spec pos(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate pos(ugen, pos), to: Ugen

  @doc """
  Sets the output level.

  ## example

      iex> sin |> freq(269) |> pan |> level(0.5) |> play
  """
  @doc since: "0.2.0"
  @spec level(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate level(ugen, pos), to: Ugen

  @doc """
  Play the composed oscillator, or a raw SuperCollider's command (as a string).

  By default, the SuperCollider command will be referenced with the variable "x".
  For example, you can stop playing it with `stop("x")`

  ## example

      iex> import Supex
      iex> sin |> freq(269) |> play
  """
  @doc since: "0.1.0"
  @spec play(struct() | binary()) :: %Sclang{}
  def play(ugen) when is_struct(ugen), do: ugen |> Command.build() |> play()

  @doc since: "0.1.0"
  def play(sc_command) when is_binary(sc_command) do
    sc_command |> Command.play() |> Sclang.execute()
  end

  @doc """
  Play the composed oscillator, or a raw SuperCollider's command (as a string),
  and naming it for referencing.

  The SuperCollider command will be referenced with the given name.
  You can stop it using `stop("<name>")`.

  While SuperCollider only accepts single characters as global variables (e.g., "y", "i"),
  longer names can be used as environment variables and will be declared accordingly.

  ## example

      iex> import Supex
      iex> sin |> freq(269) |> pan |> play("y")
      iex> stop("y")

      iex> import Supex
      iex> pulse |> freq(269) |> pan |> play("sound")
      iex> stop("sound")
  """
  @doc since: "0.2.0"
  @spec play(struct() | binary(), binary()) :: %Sclang{}
  def play(ugen, name) when is_struct(ugen) and is_binary(name) do
    ugen |> Command.build() |> play(name)
  end

  @doc since: "0.2.0"
  def play(sc_command, name) when is_binary(sc_command) and is_binary(name) do
    sc_command |> Command.play(name) |> Sclang.execute()
  end

  @doc since: "0.2.0"
  @spec stop() :: %Sclang{}
  def stop(), do: Sclang.stop_playing()

  @doc """
  Stop playing a SuperCollider command by name.

  ## example

      iex> stop("x")
  """
  @doc since: "0.1.0"
  @spec stop(binary()) :: %Sclang{}
  def stop(name) when is_binary(name), do: Command.stop(name) |> Sclang.execute()

  @doc "Stops all sound playing."
  @doc since: "0.1.0"
  @deprecated "Use Supex.stop/0 instead"
  @spec stop_playing() :: %Sclang{}
  defdelegate stop_playing(), to: Sclang

  @doc """
  Executes a raw SuperCollider command on the `sclang` server.

  Must be a string.
  """
  @doc since: "0.1.0"
  @spec execute(binary()) :: %Sclang{}
  defdelegate execute(sc_command), to: Sclang
end
