defmodule Producto do
  defstruct nombre: "", stock: 0, precio_sin_iva: 0.0, iva: 0.0

  def precio_final(%Producto{nombre: n, precio_sin_iva: p, iva: iva}) do
    {n, p * (1 + iva)}
  end
end

defmodule Benchmark2 do
  alias Producto

  def run do
    productos =
      for i <- 1..50_000 do
        %Producto{nombre: "Prod#{i}", stock: 10, precio_sin_iva: 100 + i, iva: 0.19}
      end

    IO.puts("=== SECUECIAL ===")
    {t_seq, _} = medir(fn -> Enum.map(productos, &Producto.precio_final/1) end)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, _} =
      medir(fn ->
        productos
        |> Enum.map(&Task.async(fn -> Producto.precio_final(&1) end))
        |> Enum.map(&Task.await/1)
      end)
    IO.puts("Tiempo concurrente: #{t_conc} ms")

    IO.puts("\nSpeedup: #{Float.round(t_seq / t_conc, 2)}x")
  end

  defp medir(fun) do
    {us, _} = :timer.tc(fun)
    {div(us, 1000), :ok}
  end
end

Benchmark2.run()
