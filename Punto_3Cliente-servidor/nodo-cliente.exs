defmodule NodoCliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.2"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("cliente iniciando...")
    iniciar_nodo(@nodo_cliente)
    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :punto3, :secuencial})
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
      {:orden, ordenes, :concurrente} ->
        IO.puts("Se recibio la lista de ordenes, creando los tickets de forma concurrente...")
        tickets= Orden.procesar_orden_concurrente(ordenes)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, tickets})
        IO.puts("Productos actualizados enviados al servidor.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto3, :speed_up})
        esperar_mensajes()

      {:orden, ordenes, :secuencial} ->
        IO.puts("Se recibio la lista de ordenes, creando los tickets de forma secuencial...")
        tickets= Orden.procesar_orden_secuencial(ordenes)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, tickets})
        IO.puts("Productos actualizados enviados al servidor de forma secuencial.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto3, :concurrente})
        esperar_mensajes()

      {:orden, :speed_up, ordenes}->
        IO.puts("Calculando speedup...")
        tiempo_secuencial=Benchmark.determinar_tiempo_ejecucion({Orden, :procesar_orden_secuencial, [ordenes]})
        tiempo_concurrente=Benchmark.determinar_tiempo_ejecucion({Orden, :procesar_orden_concurrente, [ordenes]})
        speedup=Benchmark.calcular_speedup(tiempo_secuencial, tiempo_concurrente)|> Float.round(2)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, :speedup, speedup})
        IO.puts("Speedup enviado al servidor.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :fin})
        esperar_mensajes()

      :fin ->
        IO.puts("servidor finalizó la conexión.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        send({@nombre_proceso, @nodo_servidor}, {self(), :fin})
        esperar_mensajes()
    end
  end
end

NodoCliente.main()
