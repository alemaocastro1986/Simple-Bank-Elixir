defmodule Usuario do
  defstruct name: nil, email: nil

  def novo(name, email) do
    %__MODULE__{name: name, email: email}
  end
end
