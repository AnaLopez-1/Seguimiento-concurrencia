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

      {productor, :punto2, :concurrente} ->
        IO.puts("Enviando la lista de productos al cliente de forma concurrente")
        productos = Productos.lista_productos()
        send(productor, {:producto, productos, :concurrente})
        procesar_mensajes()

      {productor, :punto2, :secuencial} ->
        IO.puts("Enviando la lista de productos al cliente de forma secuencial")
        productos = Productos.lista_productos()
        send(productor, {:producto, productos, :secuencial})
        procesar_mensajes()

      {productor, {:resultado, productos_actualizados}} ->
        IO.puts("\nProductos actualizados recibidos del cliente:")
        Enum.each(productos_actualizados, fn {nombre, precio_final} ->
          IO.puts("El producto #{nombre}, tiene precio final de #{precio_final} ")
        end)
        procesar_mensajes()

      {productor, :punto2, :speed_up}->
        IO.puts("Enviando el speedup al cliente")
        productos = Productos.lista_productos()
        send(productor, {:producto, :speed_up, productos})
        procesar_mensajes()

      {productor, :resultado, speedup}->
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
