defmodule NodoServidor do
  @nodo_servidor :"servidor@192.168.1.2"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("SE INICIA EL SERVIDOR")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        send(productor, :fin)

      {productor, :ordenes, :secuencial}->
        IO.puts("Enviando la lista de ordenes al cliente de forma secuencial")
        ordenes = Ordenes.lista_ordenes()
        send(productor, {:orden, ordenes, :secuencial})
        procesar_mensajes()

      {productor, :ordenes, :concurrente}->
        IO.puts("Enviando la lista de ordenes al cliente de forma concurrente")
        ordenes = Ordenes.lista_ordenes()
        send(productor, {:orden, ordenes, :concurrente})
        procesar_mensajes()

      {productor, :ordenes, :speed_up}->
        IO.puts("Enviando el speedup al cliente")
        ordenes= Ordenes.lista_ordenes()
        send(productor, {:orden, :speed_up, ordenes})
        procesar_mensajes()

      {productor, :resultado, tickets}->
        IO.puts("tickets recibidos")
        Enum.each(tickets, fn ticket -> IO.puts(ticket)  end)
        procesar_mensajes()

      {productor, :resultado, :speedup, speedup}->
        IO.puts("\nSpeedup recibido del cliente: #{speedup}")
        procesar_mensajes()

      {productor, mensaje} ->
        respuesta = procesar_mensaje(mensaje)
        send(productor, respuesta)
        procesar_mensajes()
    end
  end

  defp procesar_mensaje({:mayusculas, msg}), do: String.upcase(msg)
  defp procesar_mensaje({:minusculas, msg}), do: String.downcase(msg)
  defp procesar_mensaje({funcion, msg}) when is_function(funcion, 1), do: funcion.(msg)
  defp procesar_mensaje(mensaje), do: "El mensaje \"#{mensaje}\" es desconocido."
end

NodoServidor.main()
