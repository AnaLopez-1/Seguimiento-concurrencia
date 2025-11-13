defmodule Paquete do
  defstruct id: nil, peso: 0, fragil?: false

  def preparar(%Paquete{id: id, fragil?: fragil}) do
    t1 = :timer.tc(fn -> :timer.sleep(5) end) |> elem(0)
    t2 = :timer.tc(fn -> :timer.sleep(5) end) |> elem(0)
    if fragil, do: :timer.sleep(5)
    total_ms = div(t1 + t2, 1000) + if(fragil, do: 5, else: 0)
    {id, "Listo en #{total_ms} ms"}
  end
end

defmodule Benchmark10 do
  alias Paquete

  def run do
    paquetes = [
      %Paquete{id: 1, peso: 2, fragil?: true},
      %Paquete{id: 2, peso: 5, fragil?: false},
      %Paquete{id: 3, peso: 1, fragil?: true},
      %Paquete{id: 4, peso: 3, fragil?: false}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(paquetes, &Paquete.preparar/1) end)
    IO.inspect(r_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        paquetes |> Enum.map(&Task.async(fn -> Paquete.preparar(&1) end))
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

Benchmark10.run()
