defmodule Sucursal do
  defstruct id: nil, ventas_diarias: []

  def reporte(%Sucursal{id: id, ventas_diarias: ventas}) do
    :timer.sleep(Enum.random(50..120))
    total = Enum.sum(ventas)
    top = ventas |> Enum.sort(:desc) |> Enum.take(3)
    IO.puts("Reporte listo Sucursal #{id} (total=#{total}, top=#{inspect(top)})")
    {id, total}
  end
end

defmodule Benchmark5 do
  alias Sucursal

  def run do
    sucursales = for i <- 1..5, do: %Sucursal{id: i, ventas_diarias: Enum.take_random(100..500, 10)}

    IO.puts("=== SECUECIAL ===")
    {t_seq, _} = medir(fn -> Enum.map(sucursales, &Sucursal.reporte/1) end)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, _} =
      medir(fn ->
        sucursales |> Enum.map(&Task.async(fn -> Sucursal.reporte(&1) end))
                   |> Enum.map(&Task.await/1)
      end)
    IO.puts("Tiempo concurrente: #{t_conc} ms")
    IO.puts("\nSpeedup: #{Float.round(t_seq / t_conc, 2)}x")
  end

  defp medir(fun) do
    {us, r} = :timer.tc(fun)
    {div(us, 1000), r}
  end
end

Benchmark5.run()
