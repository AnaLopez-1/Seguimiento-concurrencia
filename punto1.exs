defmodule Car do
  defstruct id: nil, piloto: "", pit_ms: 0, vuelta_ms: []

  def simular_carrera(%Car{id: id, piloto: piloto, pit_ms: pit, vuelta_ms: vueltas}) do
    total = Enum.sum(vueltas) + pit
    Enum.each(vueltas, &:timer.sleep/1)
    :timer.sleep(pit)
    {id, piloto, total}
  end
end

defmodule Benchmark1 do
  alias Car

  def run do
    autos = [
      %Car{id: 1, piloto: "Ana", pit_ms: 50, vuelta_ms: [30, 40, 35]},
      %Car{id: 2, piloto: "Luis", pit_ms: 40, vuelta_ms: [32, 38, 37]},
      %Car{id: 3, piloto: "Marta", pit_ms: 60, vuelta_ms: [29, 42, 33]},
      %Car{id: 4, piloto: "Pablo", pit_ms: 55, vuelta_ms: [31, 39, 34]}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(autos, &Car.simular_carrera/1) end)
    mostrar_ranking(r_seq, t_seq)

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        autos |> Enum.map(&Task.async(fn -> Car.simular_carrera(&1) end))
              |> Enum.map(&Task.await/1)
      end)
    mostrar_ranking(r_conc, t_conc)

    IO.puts("\nSpeedup: #{Float.round(t_seq / t_conc, 2)}x")
  end

  defp mostrar_ranking(resultados, tiempo) do
    resultados
    |> Enum.sort_by(fn {_, _, total} -> total end)
    |> Enum.each(fn {id, piloto, total} ->
      IO.puts("#{id} - #{piloto}: #{total} ms")
    end)
    IO.puts("Tiempo total: #{tiempo} ms")
  end

  defp medir(fun) do
    {us, r} = :timer.tc(fun)
    {div(us, 1000), r}
  end
end

Benchmark1.run()
