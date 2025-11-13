defmodule Users do

  defstruct [:email, :edad, :nombre]

  def validar_usuarios_secuencial(usuarios) do
    Enum.map(usuarios, fn usuario ->
      :timer.sleep(:rand.uniform(8)+2)
      validar_usuario(usuario)
    end)
  end

  def validar_usuarios_concurrente(usuarios) do
    usuarios
    |> Enum.map(fn usuario ->
      Task.async(fn -> validar_usuario(usuario) end)
      |> Task.await()
    end)
  end

  def validar_usuario(usuario)do
    [
      validar_email(usuario),
      validar_edad(usuario),
      validar_nombre(usuario)
    ]
  end
  def validar_nombre(%Users{nombre: nombre}) do
    if String.length(nombre)>0 do
      {nombre, :ok}
    else
      {:error, "Nombre inválido"}
    end
  end

  def validar_email(%Users{email: email}) do
    if String.contains?(email, "@") do
      {email, :ok}
    else
      {:error, "Email inválido"}
    end
  end

  def validar_edad(%Users{edad: edad}) when edad >= 0 do
    {edad, :ok}
  end
  def validar_edad(%Users{edad: _edad}) do
    {:error, "Edad inválida"}
  end
end
