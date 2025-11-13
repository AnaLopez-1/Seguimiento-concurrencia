defmodule Carrera do
  @vueltas 3

  # Simula un solo auto
  def simular_carrera(%Car{piloto: piloto, vuelta_ms: vms, pit_ms: pms}) do
    total =
      Enum.reduce(1..@vueltas, 0, fn _, acc ->
        :timer.sleep(vms)
        acc + vms
      end)

    tiempo_total = total + pms
    IO.puts("#{piloto} terminó con #{tiempo_total} ms.")
    {piloto, tiempo_total}
  end

  # Procesa los autos uno por uno (secuencial)
  def carrera_secuencial(autos) do
    Enum.map(autos, &simular_carrera/1)
    |> Enum.sort_by(fn {_piloto, tiempo} -> tiempo end)
  end

    # Un proceso por auto (concurrente)
  def carrera_concurrente(autos) do

    Enum.map(autos, fn auto ->
      Task.async(fn -> simular_carrera(auto) end)
    end)
    |> Task.await_many()
    |> Enum.sort_by(fn {_piloto, tiempo} -> tiempo end)
  end

    def lista_autos do
    [
      %Car{id: 1, piloto: "Hamilton", vuelta_ms: 800, pit_ms: 400},
      %Car{id: 2, piloto: "Verstappen", vuelta_ms: 750, pit_ms: 300},
      %Car{id: 3, piloto: "Alonso", vuelta_ms: 820, pit_ms: 500},
      %Car{id: 4, piloto: "Leclerc", vuelta_ms: 790, pit_ms: 350}
    ]
  end

  def calcular_speedup() do
    lista_autos=lista_autos()
    tiempo_secuencial=Benchmark.determinar_tiempo_ejecucion({Carrera, :carrera_secuencial, [lista_autos]})
    tiempo_concurrente=Benchmark.determinar_tiempo_ejecucion({Carrera, :carrera_concurrente, [lista_autos]})
    speedup=Benchmark.calcular_speedup(tiempo_secuencial,tiempo_concurrente)
    IO.puts("El speeup es de #{speedup}")
  end

  def iniciar do
    autos = lista_autos()

    ranking1 = carrera_secuencial(autos)
    IO.puts("\nRanking SECUNCIAL:")
    Enum.each(ranking1, fn {piloto, tiempo} ->
      IO.puts("  #{piloto} - #{tiempo} ms")
    end)
    IO.puts("\n\n\n\n")

    ranking2 = carrera_concurrente(autos)
    IO.puts("\nRanking CONCURRENTE:")
    Enum.each(ranking2, fn {piloto, tiempo} ->
      IO.puts("  #{piloto} - #{tiempo} ms")
    end)

    IO.puts("\nSimulación terminada.\n")
  end
end
