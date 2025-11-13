defmodule Producto do

  defstruct [:nombre, :stock, :precio, :iva]

  def precio_final_secuencial(productos) do
    Enum.map(productos, fn producto ->
      precio_final=Float.round(producto.precio*(1+producto.iva),2)
      {producto.nombre, precio_final}
    end )
  end

  def precio_final_concurrente(productos) do
    Enum.map(productos,fn producto ->
    Task.async(fn ->
      precio_final=Float.round(producto.precio*(1+producto.iva),2)
      {producto.nombre, precio_final}
    end)
    end)
    |>Task.await_many()
  end
end
