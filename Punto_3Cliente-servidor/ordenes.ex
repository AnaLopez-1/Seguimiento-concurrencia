defmodule Ordenes do

  def lista_ordenes() do
    [
      %Orden{id: 1, item: "Hamburguesa", prep_ms: 3000},
      %Orden{id: 2, item: "Papas Fritas", prep_ms: 1500},
      %Orden{id: 3, item: "Refresco", prep_ms: 500}
    ]
  end

  def iniciar() do
    ordenes= lista_ordenes()
    IO.puts("Procesando ordenes secuencialmente:")
    ordenes_secuencial=Orden.procesar_orden_secuencial(ordenes)
    |>mostrar_tickets()
    IO.puts("Procesando ordenes concurrentemente:")
    ordenes_concurrente=Orden.procesar_orden_concurrente(ordenes)
    |>mostrar_tickets()
    calcular_speedup(ordenes)
  end

  def mostrar_tickets(tickets) do
    Enum.each(tickets, fn ticket ->
      IO.puts(ticket)
    end)
  end

  def calcular_speedup(ordenes) do
    tiempo_secuencial= Benchmark.determinar_tiempo_ejecucion({Orden, :procesar_orden_secuencial, [ordenes]})
    tiempo_concurrente= Benchmark.determinar_tiempo_ejecucion({Orden, :procesar_orden_concurrente, [ordenes]})
    speedup= Benchmark.calcular_speedup(tiempo_secuencial, tiempo_concurrente) |> Float.round(2)
    IO.puts("Speedup obtenido: #{speedup}")
  end

end
