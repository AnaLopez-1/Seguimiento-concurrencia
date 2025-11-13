defmodule NodoServidor do
  @nodo_servidor :"servidor@192.168.1.2"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("Servidor iniciando...")
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

      {productor, :usuarios, :secuencial}->
        IO.puts("\nValidando usuarios secuencialmente\n")
        usuarios=Usuarios.lista_usuarios()
        send(productor, {:user, usuarios, :secuencial})
        procesar_mensajes()

      {productor, :usuarios, :concurrente}->
        IO.puts("\nValidando usuarios concurrentemente:\n")
        usuarios=Usuarios.lista_usuarios()
        send(productor, {:user, usuarios, :concurrente})
        procesar_mensajes()

      {productor, :usuarios, :speed_up}->
        IO.puts("Enviando el speedup al cliente")
        usuarios=Usuarios.lista_usuarios()
        send(productor, {:user, :speed_up, usuarios})
        procesar_mensajes()

      {productor, :resultado, usuarios_validados}->
        IO.puts("Usuarios validados recibidos del cliente:")
        Punto6.mostrar_resultados(usuarios_validados)
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
