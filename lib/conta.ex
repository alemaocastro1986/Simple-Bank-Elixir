defmodule Conta do
  defstruct usuario: Usuario, saldo: 1000
  @contas "contas.txt"

  def cadastrar(usuario) do
    contas = get_counts()

    case get_counts_by_email(usuario) do
      nil ->
        binary =
          ([%__MODULE__{usuario: usuario}] ++ contas)
          |> :erlang.term_to_binary()

        File.write!(@contas, binary)

      _ ->
        {:error, "Account already exists."}
    end
  end

  def get_counts() do
    try do
      {:ok, binary} = File.read(@contas)
      :erlang.binary_to_term(binary)
    rescue
      ArgumentError -> []
    end
  end

  def get_counts_by_email(email) do
    get_counts()
    |> Enum.find(fn c -> c.usuario.email === email end)
  end

  def transferir(de, para, valor) do
    de = get_counts_by_email(de)
    para = get_counts_by_email(para)

    cond do
      valida_saldo(de.saldo, valor) ->
        {:error, "Saldo insuficiente"}

      true ->
        counts = delete_accounts([de, para])

        de = %Conta{de | saldo: de.saldo - valor}
        para = %Conta{para | saldo: para.saldo + valor}

        new_counts =
          (counts ++ [de, para])
          |> :erlang.term_to_binary()

        Transaction.excecute("trasferência", valor, de.usuario.email, para.usuario.email)

        File.write(@contas, new_counts)
    end
  end

  defp delete_accounts(account_delete) do
    Enum.reduce(account_delete, get_counts(), fn x, acc -> List.delete(acc, x) end)
  end

  def sacar(conta, valor) do
    conta = get_counts_by_email(conta)

    cond do
      valida_saldo(conta.saldo, valor) ->
        {:error, "Saldo insuficiente"}

      true ->
        counts = delete_accounts([conta])
        conta = %Conta{conta | saldo: conta.saldo - valor}

        binary =
          (counts ++ [conta])
          |> :erlang.term_to_binary()

        File.write!(@contas, binary)
        Transaction.excecute("Saque", valor, conta.usuario.email)

        {:ok, conta, "mensagem de email encaminhada."}
    end
  end

  defp valida_saldo(saldo, valor) do
    saldo < valor
  end
end
