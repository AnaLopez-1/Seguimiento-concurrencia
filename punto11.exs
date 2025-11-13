defmodule Comentario do
  defstruct id: nil, texto: ""

  def moderar(%Comentario{id: id, texto: txt}) do
    :timer.sleep(Enum.random(5..12))
    if contiene_prohibidas?(txt) or String.length(txt) > 100 do
      {id, :rechazado}
    else
      {id, :aprobado}
    end
  end

  defp contiene_prohibidas?(txt) do
    Enum.any?(["spam", "http", "odio"], &String.contains?(txt, &1))
  end
end

defmodule Benchmark11 do
  alias Comentario

  def run do
    comentarios = [
      %Comentario{id: 1, texto: "Me gusta este producto"},
      %Comentario{id: 2, texto: "Visita http://spam.com"},
      %Comentario{id: 3, texto: "Muy bueno!"},
      %Comentario{id: 4, texto: "Palabras de odio aquí"}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(comentarios, &Comentario.moderar/1) end)
    IO.inspect(r_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        comentarios |> Enum.map(&Task.async(fn -> Comentario.moderar(&1) end))
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

Benchmark11.run()
