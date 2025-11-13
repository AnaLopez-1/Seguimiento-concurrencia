defmodule NodoCliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.2"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("Cliente iniciando...")
    iniciar_nodo(@nodo_cliente)
    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :punto6, :secuencial})
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
      {:user, usuarios, :concurrente} ->
        IO.puts("\nSe recibieron los usuarios, validando cada uno de ellos de forma concurrente...")
        usuarios_validados=Users.validar_usuarios_concurrente(usuarios)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, usuarios_validados})
        IO.puts("Usuarios validados enviados al servidor.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto6, :speed_up})
        esperar_mensajes()

      {:user, usuarios, :secuencial} ->
        IO.puts("\nSe recibieron los usuarios, validando cada uno de ellos de forma secuencial...")
        usuarios_validados= Users.validar_usuarios_secuencial(usuarios)
        send({@nombre_proceso, @nodo_servidor}, {self(), :resultado, usuarios_validados})
        IO.puts("Usuarios validados enviados al servidor.")
        send({@nombre_proceso, @nodo_servidor}, {self(), :punto6, :concurrente})
        esperar_mensajes()

      {:user, :speed_up, usuarios}->
        speedup=Usuarios.calcular_speedup(usuarios)
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
