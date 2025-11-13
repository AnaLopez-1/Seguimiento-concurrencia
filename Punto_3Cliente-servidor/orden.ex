defmodule Orden do

  defstruct [:id, :item, :prep_ms]

  def procesar_orden_secuencial(orden) do
    Enum.map(orden, fn orden ->
      :timer.sleep(orden.prep_ms)
      "ticket #{orden.id}: #{orden.item} lista"
    end)
  end

  def procesar_orden_concurrente(orden) do
    Enum.map(orden, fn orden ->
      Task.async(fn ->
        :timer.sleep(orden.prep_ms)
        "ticket #{orden.id}: #{orden.item} lista"
      end)
    end)
    |>Task.await_many()
  end
end
