defmodule Review do

  defstruct [:id, :texto]

  def procesar_review_secuencial(reviews) do
    Enum.map(reviews, fn review ->
      :timer.sleep(:rand.uniform(11) + 4)
      {review.id, limpiar(review.texto)}
    end)
  end

  def procesar_reviwe_concurrente(reviews)do
    Enum.map(reviews, fn review ->
      Task.async(fn ->
        :timer.sleep(:rand.uniform(11) + 4)
        {review.id, limpiar(review.texto)}
      end)
    end)
    |>Task.await_many()
  end

  defp limpiar(texto)do
    String.trim(texto)
    |> String.downcase()
    |>quitar_tildes()
    |>quitar_stopwords()
  end

  defp quitar_stopwords(texto) do
    stopwords = ["el", "la", "los", "las", "un", "una", "unos", "unas",
                 "y", "o", "pero", "porque", "de", "del", "a", "en",
                 "con", "sin", "por", "para", "es", "son", "fue", "han",
                 "muy", "nada", "todo", "algo", "más", "menos"]

    palabras = String.split(texto)
    palabras_filtradas = Enum.filter(palabras, fn palabra ->
      not Enum.member?(stopwords, palabra)
    end)

    Enum.join(palabras_filtradas, " ")
  end

  defp quitar_tildes(texto) do
    texto
    |> String.replace("á", "a")
    |> String.replace("é", "e")
    |> String.replace("í", "i")
    |> String.replace("ó", "o")
    |> String.replace("ú", "u")
  end

end
