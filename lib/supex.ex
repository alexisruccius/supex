defmodule Supex do
  @moduledoc """
  [![Hex.pm](https://img.shields.io/hexpm/v/supex.svg)](https://hex.pm/packages/supex)
  [![API docs](https://img.shields.io/hexpm/v/supex.svg?label=hexdocs "API docs")](https://hexdocs.pm/supex)
  [![Hex Downloads](https://img.shields.io/hexpm/dt/supex)](https://hex.pm/packages/supex)
  [![Last Updated](https://img.shields.io/github/last-commit/alexisruccius/supex.svg)](https://github.com/alexisruccius/supex/commits/master)
  [![GitHub stars](https://img.shields.io/github/stars/alexisruccius/supex.svg)](https://github.com/alexisruccius/supex/stargazers)

  Supex = SuperCollider + Elixir

  An Elixir wrapper for the music live-coding language SuperCollider.
  Supex communicates with SuperCollider's `sclang` tool, letting you generate and control sound directly from Elixir.

  - 🎧 Play basic oscillators with a clean, pipeable syntax
  - 🔤 Send raw SuperCollider code when needed
  - ⛔ Stop sounds by name

  Built for musicians, coders, and live performers who want to use Elixir for audio synthesis.

  ## Installation

  The package can be installed by adding `supex` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
  [
    {:supex, "~> 0.2.0"}
  ]
  end
  ```

  > #### Note on v0.2.0 {: .tip}
  > The library is now fully refactored with a clear structure and consistent naming.
  > The sound naming issue in v0.1.0 has been fixed.

  > #### ⚙ Requires `sclang` to be installed {: .info}
  > Install with `sudo apt install supercollider-language` or `sudo apt install supercollider` on Ubuntu.
  > For all platforms, see [SuperCollider's installation guide](https://supercollider.github.io/downloads.html).

  ## 🔍 Learn SuperCollider basics

  https://doc.sccode.org/Tutorials/Getting-Started/00-Getting-Started-With-SC.html

  ## 🟢 Start the SuperCollider sclang server

  ```elixir
  iex> Supex.Sclang.start_link(:ok)
  ```

  ## 💡 Examples

  ▶ Play a sine oscillator at 269 Hz and name it "y", pan to center; then stop it:

  ```elixir
  iex> import Supex
  iex> sin() |> freq(269) |> pan |> play("y")
  iex> stop("y")
  ```

  ▶ Modulate volume of a sine wave using another sine as LFO:

  ```elixir
  iex> import Supex
  iex> sin() |> mul(sin() |> freq(2) |> mul(0.4) |> add(0.5) |> lfo) |> pan |> play
  iex> stop()
  ```

  ▶ Modulate a pulse wave's frequency and width:

  ```elixir
  iex> import Supex
  iex> pulse() |> freq(saw() |> freq(0.1) |> mul(100) |> add(100) |> lfo) |> width(sin() |> freq(6) |> mul(0.5) |> add(0.5) |> lfo) |> pan |> play
  iex> stop()
  ```

  🔤 Send a raw SuperCollider expression:

  ```elixir
  iex> import Supex
  iex> "RLPF.ar(Pulse.ar([100, 250], 0.5, 0.1), XLine.kr(8000, 400, 5), 0.05)" |> pan |> play
  iex> stop()
  ```
  or

  ```elixir
  iex> import Supex
  iex> execute("play{LFCub.ar(LFSaw.kr(LFPulse.kr(1/4,1/4,1/4)*2+2,1,-20,50))+(WhiteNoise.ar(LFPulse.kr(4,0,LFPulse.kr(1,3/4)/4+0.05))/8)!2}")
  iex> stop()
  ```

  ## ⚠️ Disclaimer

  SuperCollider and Supex can produce loud, sudden sounds.
  Use volume control and a limiter to protect your ears.
  Avoid hearing damage.

  ## 🛠️ Note

  Supex is in early development.
  Expect API changes.
  """
  @moduledoc since: "0.1.0"

  alias Supex.Command
  alias Supex.Sclang
  alias Supex.Ugen
  alias Supex.Ugen.Pan2
  alias Supex.Ugen.Pulse
  alias Supex.Ugen.Saw
  alias Supex.Ugen.SinOsc

  @doc """
  Create an oscillator.

  `type` can be:

    `:sin` (sinus wave)
    `:saw` (saw wave)
    `:pulse` (pulse wave, aka square wave)

  Defaults to `:sin`.
  """
  @deprecated "Use Supex.sin/0 instead."
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
  Creates a sine oscillator.

  Uses the SuperCollider SinOsc sine wave generator,
  see https://doc.sccode.org/Classes/SinOsc.html

  `freq` frequency in Hertz,

  `phase`	phase in radians (should be within the range +-8pi),

  `mul` output will be multiplied by this value,

  `add` this value will be added to the output.

  For setting these values use `freq/2`, `phase/2`, `mul/2`, `add/2`, and `lfo/1`.

  ## examples

      iex> import Supex
      iex> sin() |> pan |> play
      iex> stop("x")

      iex> import Supex
      iex> sin() |> freq(369) |> phase(0.1) |> mul(0.2) |> add(0.3) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.2.0"
  @spec sin() :: %SinOsc{}
  defdelegate sin(), to: Ugen

  @doc """
  Create a saw oscillator.

  Uses the SuperCollider Saw wave generator,
  see https://doc.sccode.org/Classes/Saw.html

  `freq` frequency in Hertz,

  `mul` output will be multiplied by this value,

  `add` this value will be added to the output.

  For setting these values use `freq/2`, `mul/2`, `add/2`, and `lfo/1`.

  ## example

      iex> import Supex
      iex> saw() |> pan |> play
      iex> stop("x")

      iex> import Supex
      iex> saw() |> freq(369) |> mul(0.2) |> add(0.3) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.2.0"
  @spec saw() :: %Saw{}
  defdelegate saw(), to: Ugen

  @doc """
  Create a pulse oscillator.

  Uses the SuperCollider Pulse wave generator,
  see https://doc.sccode.org/Classes/Pulse.html

  `freq` frequency in Hertz,

  `width` pulse width ratio from zero to one (0.5 makes a square wave)

  `mul` output will be multiplied by this value,

  `add` this value will be added to the output.

  For setting these values use `freq/2`, `width/2`, `mul/2`, `add/2`, and `lfo/1`.

  ## examples

      iex> import Supex
      iex> pulse() |> pan |> play
      iex> stop("x")

      iex> import Supex
      iex> pulse() |> freq(369) |> width(0.6) |> mul(0.2) |> add(0.3) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.2.0"
  @spec pulse() :: %Pulse{}
  defdelegate pulse(), to: Ugen

  @doc """
  Transforms a "normal" oscillator to a LFO to use it as a modulator.

  It uses `kr` (control rate) instead of `ar`(audio rate),
  cf. https://doc.sccode.org/Tutorials/Getting-Started/05-Functions-and-Sound.html

  ## examples

  Modulate the volume of a sine wave with another sine wave as an LFO:

      iex> import Supex
      iex> sin() |> mul(sin() |> freq(3) |> mul(0.5) |> add(0.5) |> lfo) |> pan |> play
      iex> stop()

      iex> import Supex
      iex> pulse() |> mul(sin() |> freq(2) |> mul(0.4) |> add(0.5) |> lfo) |> freq(saw() |> freq(0.2) |> mul(100) |> add(100) |> lfo) |> pan |> play
      iex> stop()
  """
  @doc since: "0.1.0"
  @spec lfo(struct()) :: struct()
  defdelegate lfo(ugen), to: Ugen

  @doc """
  Tune the frequency of an oscillator.

  ## examples

      iex> import Supex
      iex> pulse() |> freq(369) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.1.0"
  @spec freq(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate freq(ugen, freq), to: Ugen

  @doc """
  The pulse width of a pulse wave oscillator.

  `width` should be a value between `0.01` and `0.99`.

  ## examples

      iex> import Supex
      iex> pulse() |> width(0.6) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.1.0"
  @spec width(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate width(ugen, width), to: Ugen

  @doc """
  The phase of a sinus wave.

  ## examples

      iex> import Supex
      iex> saw() |> freq(369) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.1.0"
  @spec phase(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate phase(ugen, phase), to: Ugen

  @doc """
  Multiplication of the signal.

  Choose values between `0.1` and `1` for not hurting your ears.

  ## examples

      iex> import Supex
      iex> pulse() |> mul(0.2) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.1.0"
  @spec mul(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate mul(ugen, mul), to: Ugen

  @doc """
  Add the value to the signal.

  Values can be `0.1` or `1` for example.

  ## examples

      iex> import Supex
      iex> pulse() |> add(0.3) |> pan |> play("y")
      iex> stop("y")
  """
  @doc since: "0.1.0"
  @spec add(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate add(ugen, add), to: Ugen

  @doc """
  Pans the mono signal in the stereo spectrum.

  Defaults to centering the signal.

  Use `pos/2` for panning the position (-1.0 = left, 0 = center, 1.0 = right).

  Use `level/2` for scaling the output level.

  ## example

      iex> import Supex
      iex> sin() |> freq(269) |> pan |> pos(0.69) |> play
  """
  @doc since: "0.2.0"
  @spec pan(struct()) :: %Pan2{}
  defdelegate pan(ugen), to: Ugen

  @doc """
  Pan position -1.0 = left, 0 = center, 1.0 = right

  ## example

  Pan a sound slightly to the right:

      iex> import Supex
      iex> sin() |> freq(269) |> pan |> pos(0.69) |> play
  """
  @doc since: "0.2.0"
  @spec pos(struct(), integer() | float() | binary() | struct()) :: struct()
  defdelegate pos(ugen, pos), to: Ugen

  @doc """
  Sets the output level.

  ## example

      iex> import Supex
      iex> sin() |> freq(269) |> pan |> level(0.5) |> play
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
      iex> sin() |> freq(269) |> play
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
  You can stop it using `stop/1`.

  While SuperCollider only accepts single characters as global variables (e.g., "x", "y", "z"),
  longer names can be used as environment variables and will be declared accordingly.

  Note: Do not use `"s"` as a name — it's globally reserved for the SuperCollider server.
  If `"s"` is used, it will automatically default to `"x"`.

  ## examples

      iex> import Supex
      iex> sin() |> freq(269) |> pan |> play("y")
      iex> stop("y")

      iex> import Supex
      iex> pulse() |> freq(269) |> pan |> play("sound")
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

  @doc """
  Stop playing all SuperCollider sounds.

  Use `stop/1` to stop sound named with `play/2`.

  ## example

      iex> import Supex
      iex> sin() |> pan |> play()
      iex> pulse() |> pan |> play()
      iex> stop()
  """
  @doc since: "0.2.0"
  @spec stop() :: %Sclang{}
  def stop(), do: Sclang.stop_playing()

  @doc """
  Stop playing a SuperCollider command by name.

  `play/1` defaults to `"x"`.

  Use `play/2` to set a name.

  ## example

      iex> import Supex
      iex> sin() |> pan |> play()
      iex> stop("x")

      iex> import Supex
      iex> sin() |> pan |> play("y")
      iex> stop("y")
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

  ## example

      iex> import Supex
      iex> execute("play{LFCub.ar(LFSaw.kr(LFPulse.kr(1/4,1/4,1/4)*2+2,1,-20,50))+(WhiteNoise.ar(LFPulse.kr(4,0,LFPulse.kr(1,3/4)/4+0.05))/8)!2}")
      iex> stop()
  """
  @doc since: "0.1.0"
  @spec execute(binary()) :: %Sclang{}
  defdelegate execute(sc_command), to: Sclang
end
