# Supex

[![Build Status](https://github.com/alexisruccius/supex/workflows/CI/badge.svg)](https://github.com/alexisruccius/supex/actions/workflows/CI.yml)
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
