defmodule NodoCliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.2"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("Cliente iniciando...")
    iniciar_nodo(@nodo_cliente)
    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :punto5, :secuencial})
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
      {:sucursal, sucursales, :concurrente} ->
        IO.puts("\nSe recibieron las sucursales, procesando los reportes de forma concurrentemente...")
        reportes= Sucursal.reporte_sucursal_secuencial(sucursales)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, reportes})
        IO.puts("Reportes actualizados enviados al servidor.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto5, :speed_up})
        esperar_mensajes()

      {:sucursal, sucursales, :secuencial} ->
        IO.puts("\nSe recibieron las sucursales, procesando los reportes de forma secuencial...")
        reportes= Sucursal.reporte_sucursal_concurrente(sucursales)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, reportes})
        IO.puts("Reportes enviados al servidor de forma secuencial.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto5, :concurrente})
        esperar_mensajes()

      {:sucursal, :speed_up, sucursales}->
        speedup=Sucursales.calcular_speedup(sucursales)
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
