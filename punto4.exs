defmodule Review do
  defstruct id: nil, texto: ""

  def limpiar(%Review{id: id, texto: texto}) do
    :timer.sleep(Enum.random(5..15))
    limpio =
      texto
      |> String.downcase()
      |> quitar_tildes()
      |> quitar_stopwords()

    {id, String.slice(limpio, 0, 40)}
  end

  defp quitar_tildes(t) do
    t
    |> String.replace("á", "a")
    |> String.replace("é", "e")
    |> String.replace("í", "i")
    |> String.replace("ó", "o")
    |> String.replace("ú", "u")
  end

  defp quitar_stopwords(t) do
    stop = ["el", "la", "los", "las", "un", "una", "de", "en"]
    Enum.reduce(stop, t, fn s, acc -> String.replace(acc, " #{s} ", " ") end)
  end
end

defmodule Benchmark4 do
  alias Review

  def run do
    reviews = for i <- 1..10, do: %Review{id: i, texto: "Excelente el producto #{i} de la tienda"}

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(reviews, &Review.limpiar/1) end)
    IO.inspect(r_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        reviews |> Enum.map(&Task.async(fn -> Review.limpiar(&1) end))
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

Benchmark4.run()
