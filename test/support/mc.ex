defmodule Support.MC do
  @moduledoc false

  use SMPPEX.Session

  alias SMPPEX.MC
  alias SMPPEX.Pdu
  alias SMPPEX.Pdu.Factory, as: PduFactory

  def start(port, accept \\ true) do
    MC.start(
      {__MODULE__, [accept]},
      transport_opts: %{
        socket_opts: [
          port: port
        ]
      },
      session_module: SMPPEXTelemetry.Session
    )
  end

  def stop(ref), do: MC.stop(ref)

  @impl true
  def init(_socket, _transport, [accept]) do
    if accept do
      {:ok, 0}
    else
      {:stop, :ooops}
    end
  end

  @impl true
  def handle_pdu(pdu, last_id) do
    case Pdu.command_name(pdu) do
      :bind_transceiver ->
        {:ok, [PduFactory.bind_transceiver_resp(0) |> Pdu.as_reply_to(pdu)], last_id}

      _ ->
        {:ok, last_id}
    end
  end
end
