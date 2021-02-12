defmodule Transaction do
  defstruct date: NaiveDateTime.local_now(), type: nil, value: 0, from: nil, to: nil
  @transactions "transactions.txt"

  def excecute(type, value, from, to \\ nil) do
    transaction = [
      %__MODULE__{date: NaiveDateTime.local_now(), type: type, value: value, from: from, to: to}
    ]

    transactions = get_trasactions()

    binary =
      (transactions ++ transaction)
      |> :erlang.term_to_binary()

    File.write(@transactions, binary)
  end

  @spec get_all :: list
  def get_all(), do: get_trasactions()

  @spec get_all(String.t()) :: list
  def get_all(filter) do
    transactions = get_trasactions()
    Enum.filter(transactions, fn x -> x.from == filter || x.to == filter end)
  end

  defp get_trasactions do
    if !File.exists?(@transactions) do
      File.write(@transactions, :erlang.term_to_binary([]))
    end

    try do
      File.read!(@transactions)
      |> :erlang.binary_to_term()
    rescue
      ArgumentError -> File.write(@transactions, :erlang.term_to_binary([]))
    end
  end
end
