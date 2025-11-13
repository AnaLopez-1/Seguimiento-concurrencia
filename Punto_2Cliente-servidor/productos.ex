
defmodule Productos do
  def lista_productos() do
  productos = [
  %Producto{nombre: "Producto A", stock: 10, precio: 100.0, iva: 0.21},
  %Producto{nombre: "Producto B", stock: 5, precio: 200.0, iva: 0.10},
  %Producto{nombre: "Producto C", stock: 20, precio: 50.0, iva: 0.15},
  %Producto{nombre: "Producto D", stock: 8, precio: 180.0, iva: 0.19}
]
  end
def iniciar do
    productos = lista_productos()
    resultados = Producto.precio_final_secuencial(productos)
    IO.puts("Resultados Secuenciales:")
    Enum.each(resultados, fn {nombre, precio_final} ->
      IO.puts("El precio final de #{nombre} es #{precio_final}")
    end)

    resultados_concurrentes = Producto.precio_final_concurrente(productos)
    IO.puts("\nResultados Concurrentes:")
    Enum.each(resultados_concurrentes, fn {nombre, precio_final} ->
      IO.puts("El precio final de #{nombre} es #{precio_final}")
    end)

    tiempo_secuencial= Benchmark.determinar_tiempo_ejecucion({Producto, :precio_final_secuencial, [productos]})
    tiempo_concurrente= Benchmark.determinar_tiempo_ejecucion({Producto, :precio_final_concurrente, [productos]})
    speedup=Benchmark.calcular_speedup(tiempo_secuencial,tiempo_concurrente)|> Float.round(2)
    IO.puts("\nSpeedup: #{speedup}")
  end
end
