defmodule Backoffice do
  def ejecutar(:reindex) do
    :timer.sleep(15)
    "OK tarea reindex"
  end

  def ejecutar(:purge_cache) do
    :timer.sleep(10)
    "OK tarea purge_cache"
  end

  def ejecutar(:build_sitemap) do
    :timer.sleep(20)
    "OK tarea build_sitemap"
  end

  def ejecutar(otra) do
    :timer.sleep(8)
    "OK tarea #{otra}"
  end
end

defmodule Benchmark8 do
  alias Backoffice

  def run do
    tareas = [:reindex, :purge_cache, :build_sitemap, :optimize_db, :update_stats]

    IO.puts("=== SECUECIAL ===")
    {t_seq, res_seq} = medir(fn -> Enum.map(tareas, &Backoffice.ejecutar/1) end)
    IO.inspect(res_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, res_conc} =
      medir(fn ->
        tareas |> Enum.map(&Task.async(fn -> Backoffice.ejecutar(&1) end))
               |> Enum.map(&Task.await/1)
      end)

    IO.inspect(res_conc)
    IO.puts("Tiempo concurrente: #{t_conc} ms")
    IO.puts("\nSpeedup: #{Float.round(t_seq / t_conc, 2)}x")
  end

  defp medir(fun) do
    {us, r} = :timer.tc(fun)
    {div(us, 1000), r}
  end
end

Benchmark8.run()
