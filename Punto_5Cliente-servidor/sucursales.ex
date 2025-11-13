defmodule Sucursales do
  def lista_sucursales() do
    [
      %Sucursal{id: 1, ventas_diarias: [1500, 2000, 1700, 2200, 1900]},
      %Sucursal{id: 2, ventas_diarias: [2500, 3000, 2800, 3200, 3100]},
      %Sucursal{id: 3, ventas_diarias: [1200, 1300, 1250, 1400, 1350]}
    ]
  end

  def iniciar() do
    sucursales=lista_sucursales()
    IO.puts("Procesando reportes secuencialmente:")
    Sucursal.reporte_sucursal_secuencial(sucursales)
    |>mostrar_reportes()
    IO.puts("\nProcesando reportes concurrentemente:")
    Sucursal.reporte_sucursal_concurrente(sucursales)
    |>mostrar_reportes()
    calcular_speedup(sucursales)
  end

  def calcular_speedup(sucursales) do
    IO.puts("\nCalculando speedup:")
    tiempo_secuencial=Benchmark.determinar_tiempo_ejecucion({Sucursal, :reporte_sucursal_secuencial, [sucursales]})
    tiempo_concurrente=Benchmark.determinar_tiempo_ejecucion({Sucursal, :reporte_sucursal_concurrente, [sucursales]})
    Benchmark.calcular_speedup(tiempo_secuencial, tiempo_concurrente) |> Float.round(2)
  end

  def mostrar_reportes(reportes) do
    Enum.each(reportes, fn reporte ->
      IO.puts("Reporte listo #{reporte}")
    end)
  end

end
