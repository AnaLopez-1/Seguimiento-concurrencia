defmodule Carrito do
  defstruct id: nil, items: [], cupon: nil

  # Cada item tiene: %{nombre: "Producto", categoria: "A", precio: 100, cantidad: 2}

  # Reglas de descuento:
  # - cupón: aplica un % general (ej: "DESC10" => 10%)
  # - descuento por categoría: 20% en categoría "A"
  # - 2x1 en categoría "B"
  def total_con_descuentos(%Carrito{id: id, items: items, cupon: cupon}) do
    # Simula trabajo pesado (procesamiento de descuentos)
    :timer.sleep(Enum.random(5..15))

    total_items =
      items
      |> Enum.map(&aplicar_descuentos_item(&1))
      |> Enum.sum()

    total_cupon = aplicar_cupon(total_items, cupon)
    {id, total_cupon}
  end

  defp aplicar_descuentos_item(%{categoria: "A", precio: p, cantidad: c}) do
    # 20% de descuento
    (p * c) * 0.8
  end

  defp aplicar_descuentos_item(%{categoria: "B", precio: p, cantidad: c}) do
    # 2x1 (solo paga la mitad redondeando hacia arriba)
    pagas = Float.ceil(c / 2)
    p * pagas
  end

  defp aplicar_descuentos_item(%{precio: p, cantidad: c}) do
    p * c
  end

  defp aplicar_cupon(total, nil), do: total
  defp aplicar_cupon(total, "DESC10"), do: total * 0.9
  defp aplicar_cupon(total, "DESC20"), do: total * 0.8
  defp aplicar_cupon(total, _), do: total
end
