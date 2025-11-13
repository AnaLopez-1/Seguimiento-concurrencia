defmodule Punto6 do

  def lista_usuarios() do
    usuarios = [
    %Users{email: "ana@gmail.com", edad: 20, nombre: "Ana"},
    %Users{email: "jimmy@gmail.com", edad: 18, nombre: "Jimmy"},
    %Users{email: "maritza@gmail.com", edad: 21, nombre: "Maritza"},]
  end

  def iniciar() do
    usuarios=lista_usuarios()
    IO.puts("Validando usuarios secuencialmente:")
    Users.validar_usuarios_secuencial(usuarios)
    |>mostrar_resultados()
    IO.puts("\nValidando usuarios concurrentemente:")
    Users.validar_usuarios_concurrente(usuarios)
    |>mostrar_resultados()
    calcular_speedup(usuarios)
  end

  def calcular_speedup(usuarios) do
    tiempo_secuencial=Benchmark.determinar_tiempo_ejecucion({Users, :validar_usuarios_secuencial, [usuarios]})
    tiempo_concurrente=Benchmark.determinar_tiempo_ejecucion({Users, :validar_usuarios_concurrente, [usuarios]})
    Benchmark.calcular_speedup(tiempo_secuencial, tiempo_concurrente) |> Float.round(4)
  end

  def mostrar_resultados(resultados) do
    Enum.each(resultados, fn resultado ->
      IO.inspect(resultado)
    end)
  end
end
