# Ejecutar con: elixir --sname cliente --cookie my_cookie nodo-cliente.exs
Node.start(:"cliente@localhost")
Node.set_cookie(:my_cookie)

{:ok, _} = Node.connect(:"servidor@localhost")

IO.puts("Conectado al nodo servidor")

pid_servidor = :global.whereis_name(:benchmark_server)

send(pid_servidor, {:benchmark, self()})

receive do
  {:resultado, result} ->
    IO.puts("Resultado recibido del servidor:")
    IO.inspect(result)
end
