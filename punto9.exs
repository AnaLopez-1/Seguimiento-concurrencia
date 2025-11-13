defmodule Notif do
  defstruct canal: nil, usuario: nil, plantilla: nil

  def enviar(%Notif{canal: canal, usuario: user}) do
    :timer.sleep(costo(canal))
    "Enviada a #{user} (#{canal})"
  end

  defp costo(:push), do: 5
  defp costo(:email), do: 10
  defp costo(:sms), do: 15
end

defmodule Benchmark9 do
  alias Notif

  def run do
    notifs = [
      %Notif{canal: :push, usuario: "Ana", plantilla: "promo"},
      %Notif{canal: :email, usuario: "Luis", plantilla: "alert"},
      %Notif{canal: :sms, usuario: "Carlos", plantilla: "aviso"},
      %Notif{canal: :push, usuario: "Marta", plantilla: "saludo"}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(notifs, &Notif.enviar/1) end)
    IO.inspect(r_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        notifs |> Enum.map(&Task.async(fn -> Notif.enviar(&1) end))
               |> Enum.map(&Task.await/1)
      end)

    IO.inspect(r_conc)
    IO.puts("Tiempo concurrente: #{t_conc} ms")
    IO.puts("\nSpeedup: #{Float.round(t_seq / t_conc, 2)}x")
  end

  defp medir(fun) do
    {us, r} = :timer.tc(fun)
    {div(us, 1000), r}
  end
end

Benchmark9.run()
