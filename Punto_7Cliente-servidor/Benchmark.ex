defmodule Benchmark do
  alias Carrito

  def run do
    carritos = [
      %Carrito{id: 1, cupon: "DESC10", items: ejemplo_items()},
      %Carrito{id: 2, cupon: nil, items: ejemplo_items()},
      %Carrito{id: 3, cupon: "DESC20", items: ejemplo_items()},
      %Carrito{id: 4, cupon: nil, items: ejemplo_items()}
    ]

    IO.puts("=== EJECUCIÓN SECUENCIAL ===")
    {tiempo_seq, res_seq} = medir_tiempo(fn -> procesar_secuencial(carritos) end)
    IO.inspect(res_seq)
    IO.puts("Tiempo secuencial: #{tiempo_seq} ms")

    IO.puts("\n=== EJECUCIÓN CONCURRENTE ===")
    {tiempo_conc, res_conc} = medir_tiempo(fn -> procesar_concurrente(carritos) end)
    IO.inspect(res_conc)
    IO.puts("Tiempo concurrente: #{tiempo_conc} ms")

    speedup = Float.round(tiempo_seq / tiempo_conc, 2)
    IO.puts("\nSpeedup: #{speedup}x más rápido")
  end

  defp procesar_secuencial(carritos) do
    Enum.map(carritos, &Carrito.total_con_descuentos/1)
  end

  defp procesar_concurrente(carritos) do
    carritos
    |> Enum.map(fn carrito ->
      Task.async(fn -> Carrito.total_con_descuentos(carrito) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  defp medir_tiempo(fun) do
    {us, result} = :timer.tc(fun)
    {div(us, 1000), result}
  end

  defp ejemplo_items do
    [
      %{nombre: "Camisa", categoria: "A", precio: 50, cantidad: 2},
      %{nombre: "Zapatos", categoria: "B", precio: 100, cantidad: 3},
      %{nombre: "Pantalón", categoria: "C", precio: 80, cantidad: 1}
    ]
  end
end
