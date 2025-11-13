# Ejecutar con: elixir --sname servidor --cookie my_cookie nodo-servidor.exs
Node.start(:"servidor@localhost")
Node.set_cookie(:my_cookie)
IO.puts("Nodo servidor iniciado: #{inspect Node.self()}")

:global.register_name(:benchmark_server, self())

receive do
  {:benchmark, pid} ->
    IO.puts("Recibida petición de benchmark...")
    result = Benchmark.run()
    send(pid, {:resultado, result})
end
