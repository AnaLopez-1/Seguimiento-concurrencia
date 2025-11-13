defmodule Tpl do
  defstruct id: nil, nombre: "", vars: %{}

  def render(%Tpl{id: id, nombre: tpl, vars: vars}) do
    html =
      Enum.reduce(vars, tpl, fn {k, v}, acc ->
        String.replace(acc, "{#{k}}", to_string(v))
      end)

    :timer.sleep(String.length(tpl) * 2)
    {id, html}
  end
end

defmodule Benchmark12 do
  alias Tpl

  def run do
    plantillas = [
      %Tpl{id: 1, nombre: "<h1>Hola {nombre}</h1>", vars: %{nombre: "Ana"}},
      %Tpl{id: 2, nombre: "<p>Tu pedido #{pedido} está listo</p>", vars: %{pedido: 123}},
      %Tpl{id: 3, nombre: "<b>{producto}</b> cuesta ${precio}", vars: %{producto: "Camisa", precio: 80}}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(plantillas, &Tpl.render/1) end)
    IO.inspect(r_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        plantillas |> Enum.map(&Task.async(fn -> Tpl.render(&1) end))
                   |> Enum.map(&Task.await/1)
      end)

    IO.inspect(r_conc)
    IO.puts("Tiempo concurrente: #{t_conc} ms")
    IO.puts("\nSpeedup: #{Float.round(t_seq / t_conc, 2)}x")
  end

  defp medir(fun) do
    {us, r} = :timer.tc(fun)
    {div(us, 1000), r}
  end
end

Benchmark12.run()
