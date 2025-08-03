defmodule Supex.Command do
  @moduledoc """
  Module for SuperCollider commands rendering.
  """
  @moduledoc since: "0.2.0"

  alias Supex.Ugen

  @doc """
  Builds the SuperCollider command from a ugen struct.
  """
  @doc since: "0.2.0"
  @spec build(Ugen.t()) :: binary()
  def build(ugen), do: ugen |> to_sc_command()

  @doc """
  Adding play to the sc_command.

  By default, the SuperCollider command will be referenced with the variable "x".
  For example, you can stop playing it with `stop("x")`
  """
  @doc since: "0.2.0"
  @spec play(binary()) :: binary()
  def play(sc_command), do: "x = { " <> sc_command <> " }.play"

  @doc """
  Adding play to the sc_command, and naming it for referencing.

  The SuperCollider command will be referenced with the given name.
  You can stop it using `stop("<name>")`.

  While SuperCollider only accepts single characters as global variables (e.g., "y", "i"),
  longer names can be used as environment variables and will be declared accordingly.

  Note: Do not use `"s"` as a name — it's globally reserved for the SuperCollider server.
  If `"s"` is used, it will automatically default to `"x"`.
  """
  @doc since: "0.2.0"
  @spec play(binary(), binary()) :: binary()
  # do not use "s" as a name — it's globally reserved for the SuperCollider server
  def play(sc_command, name) when name == "s", do: play(sc_command)

  def play(sc_command, name) when byte_size(name) == 1,
    do: name <> " = { " <> sc_command <> " }.play"

  def play(sc_command, name), do: "~" <> name <> " = { " <> sc_command <> " }.play"

  @doc """
  Command for stopping sound playing referenced by name.
  """
  @doc since: "0.2.0"
  @spec stop(binary()) :: binary()
  def stop(name) when byte_size(name) == 1, do: name <> ".free\n"
  def stop(name), do: "~" <> name <> ".free\n"

  defp to_sc_command(ugen) when is_struct(ugen) do
    struct_module = ugen.__struct__
    ugen |> build_commands_for_lfos() |> struct_module.command()
  end

  defp build_commands_for_lfos(ugen) do
    new_key_values =
      ugen |> Map.from_struct() |> Enum.map(fn {k, v} -> {k, check_for_struct(v)} end)

    ugen |> struct!(new_key_values)
  end

  defp check_for_struct(value) when is_struct(value), do: value |> to_sc_command()
  defp check_for_struct(value), do: value
end
