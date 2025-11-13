defmodule Orden do
  defstruct id: nil, item: "", prep_ms: 0

  def preparar(%Orden{id: id, item: item, prep_ms: ms}) do
    :timer.sleep(ms)
    "Ticket #{id}: #{item} listo (#{ms} ms)"
  end
end

defmodule Benchmark3 do
  alias Orden

  def run do
    ordenes = [
      %Orden{id: 1, item: "Café", prep_ms: 30},
      %Orden{id: 2, item: "Sandwich", prep_ms: 50},
      %Orden{id: 3, item: "Jugo", prep_ms: 40},
      %Orden{id: 4, item: "Té", prep_ms: 20}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, res_seq} = medir(fn -> Enum.map(ordenes, &Orden.preparar/1) end)
    IO.inspect(res_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, res_conc} =
      medir(fn ->
        ordenes |> Enum.map(&Task.async(fn -> Orden.preparar(&1) end))
                |> Enum.map(&Task.await/1)
      end)
    IO.inspect(res_conc)
    IO.puts("Tiempo concurrente: #{t_conc} ms")

    IO.puts("\nSpeedup: #{Float.round(t_seq / t_conc, 2)}x")
  end

  defp medir(fun) do
    {us, r} = :timer.tc(fun)
    {div(us, 1000), r}
  end
end

Benchmark3.run()
