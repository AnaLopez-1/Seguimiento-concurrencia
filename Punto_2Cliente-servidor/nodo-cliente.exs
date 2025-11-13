defmodule NodoCliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.2"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("cliente iniciando...")
    iniciar_nodo(@nodo_cliente)
    if Node.connect(@nodo_servidor) do
      IO.puts(" Conectado al servidor.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :punto2, :concurrente})
      esperar_mensajes()
    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp esperar_mensajes() do
    receive do
      {:producto, productos, :concurrente} ->
        IO.puts("Se recibio la lista de productos, calculando precios finales...")
        productos_actualizados= Producto.precio_final_concurrente(productos)
        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado, productos_actualizados}})
        IO.puts("Productos actualizados enviados al servidor.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto2, :secuencial})
        esperar_mensajes()

      {:producto, productos, :secuencial} ->
        IO.puts("Se recibio la lista de productos, calculando precios finales de forma secuencial...")
        productos_actualizados= Producto.precio_final_secuencial(productos)
        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado, productos_actualizados}})
        IO.puts("Productos actualizados enviados al servidor de forma secuencial.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto2, :speed_up})
        esperar_mensajes()

      {:producto, :speed_up, productos}->
        IO.puts("Calculando speedup...")
        tiempo_secuencial=Benchmark.determinar_tiempo_ejecucion({Producto, :precio_final_secuencial, [productos]})
        tiempo_concurrente=Benchmark.determinar_tiempo_ejecucion({Producto, :precio_final_concurrente, [productos]})
        speedup=Benchmark.calcular_speedup(tiempo_secuencial, tiempo_concurrente)|> Float.round(2)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, speedup})
        IO.puts("Speedup enviado al servidor.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :fin})
        esperar_mensajes()

      :fin ->
        IO.puts("servidor finalizó la conexión.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

NodoCliente.main()
