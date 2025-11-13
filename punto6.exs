defmodule User do
  defstruct email: "", edad: 0, nombre: ""

  def validar(%User{email: e, edad: edad, nombre: n}) do
    :timer.sleep(Enum.random(3..10))
    errores = []
    |> maybe_add(!String.contains?(e, "@"), "email inválido")
    |> maybe_add(edad < 0, "edad negativa")
    |> maybe_add(String.trim(n) == "", "nombre vacío")

    if errores == [], do: {e, :ok}, else: {e, {:error, errores}}
  end

  defp maybe_add(lista, true, err), do: [err | lista]
  defp maybe_add(lista, false, _), do: lista
end

defmodule Benchmark6 do
  alias User

  def run do
    usuarios = [
      %User{email: "ana@mail.com", edad: 20, nombre: "Ana"},
      %User{email: "badmail.com", edad: 30, nombre: "Luis"},
      %User{email: "marta@mail.com", edad: -1, nombre: "Marta"},
      %User{email: " ", edad: 22, nombre: ""}
    ]

    IO.puts("=== SECUECIAL ===")
    {t_seq, r_seq} = medir(fn -> Enum.map(usuarios, &User.validar/1) end)
    IO.inspect(r_seq)
    IO.puts("Tiempo secuencial: #{t_seq} ms")

    IO.puts("\n=== CONCURRENTE ===")
    {t_conc, r_conc} =
      medir(fn ->
        usuarios |> Enum.map(&Task.async(fn -> User.validar(&1) end))
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

Benchmark6.run()
