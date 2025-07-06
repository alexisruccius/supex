defmodule Supex.Sclang.ScPort do
  @moduledoc """
  Port to the SuperCollider's command line tool `sclang`.
  """

  @doc """
  Opens a port to SC's `sclang.`
  """
  @doc since: "0.1.0"
  @spec open() :: port()
  def open(), do: Port.open({:spawn, "sclang"}, [:binary])

  @doc since: "0.1.0"
  @spec close(atom() | port()) :: true
  def close(port), do: Port.close(port)

  @doc """
  Sends a SuperCollider's command to the `sclang` via the port.
  """
  @doc since: "0.1.0"
  @spec send_sc_command(binary(), atom() | pid() | port() | reference() | {atom(), atom()}) ::
          {atom() | pid() | port() | reference() | {atom(), atom()},
           {:command, nonempty_binary()}}
  def send_sc_command(sc_command, port) do
    sc_cmd_cleaned = sc_command |> only_execute_full_command()
    send(port, {self(), {:command, sc_cmd_cleaned}})
    {port, {:command, sc_cmd_cleaned}}
  end

  defp only_execute_full_command(sc_command) do
    # sclang executes SC commands after a line break,
    # so the command should only have a line break at the end.
    sc_command |> String.replace("\n", "") |> Kernel.<>("\n")
  end
end
