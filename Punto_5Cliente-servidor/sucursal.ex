defmodule Sucursal do

  defstruct [:id, :ventas_diarias]

  defp generar_reporte(sucursal) do
    total_ventas=Enum.sum(sucursal.ventas_diarias)
    promedio=Float.round(total_ventas /length(sucursal.ventas_diarias),2)
    top_tres=sucursal.ventas_diarias |>Enum.sort(:desc) |>Enum.take(3)
    "Reporte sucursal #{sucursal.id}\n total ventas: #{total_ventas}\n promedio diario: #{promedio}\n top tres ventas: #{Enum.join(top_tres, ", ")}"
  end

  def reporte_sucursal_secuencial(sucursales) do
    Enum.map(sucursales, fn sucursal ->
      :timer.sleep(:rand.uniform(71)+49)
      generar_reporte(sucursal)
    end)
  end

  def reporte_sucursal_concurrente(sucursales) do
    Enum.map(sucursales, fn sucursal ->
      Task.async(fn ->
        :timer.sleep(:rand.uniform(71)+49)
        generar_reporte(sucursal)
      end)
      |>Task.await()
    end)
  end
end

