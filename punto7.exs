defmodule Carrito do
  defstruct id: nil, items: [], cupon: nil

  def total_con_descuentos(%Carrito{id: id, items: items, cupon: cupon}) do
    :timer.sleep(Enum.random(5..15))

    total_items =
      items
      |> Enum.map(&aplicar_descuentos_item(&1))
      |> Enum.sum()

    total_cupon = aplicar_cupon(total_items, cupon)
    {id, total_cupon}
  end

  defp aplicar_descuentos_item(%{categoria: "A", precio: p, cantidad: c}), do: (p * c) * 0.8
  defp aplicar_descuentos_item(%{categoria: "B", precio: p, cantidad: c}), do: p * Float.ceil(c / 2)
  defp aplicar_descuentos_item(%{precio: p, cantidad: c}), do: p * c

  defp aplicar_cupon(total, nil), do: total
  defp aplicar_cupon(total, "DESC10"), do: total * 0.9
  defp aplicar_cupon(total, "DESC20"), do: total * 0.8
  defp aplicar_cupon(total, _), do: total
end

defmodule Benchmark7 do
  alias Carrito

  def run do
    carritos = [
      %Carrito{id: 1, cupon: "DESC10", items: ejemplo_items()},
      %Carrito{id: 2, cupon: nil, items: ejemplo_items()},
      %Carrito{id: 3, cupon: "DESC20", items: ejemplo_items()},
      %Carrito{id: 4, cupon: nil, items: ejemplo_items()}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(carritos, &Carrito.total_con_descuentos/1) end)
    IO.inspect(r_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        carritos |> Enum.map(&Task.async(fn -> Carrito.total_con_descuentos(&1) end))
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

  defp ejemplo_items do
    [
      %{nombre: "Camisa", categoria: "A", precio: 50, cantidad: 2},
      %{nombre: "Zapatos", categoria: "B", precio: 100, cantidad: 3},
      %{nombre: "Pantalón", categoria: "C", precio: 80, cantidad: 1}
    ]
  end
end

Benchmark7.run()
