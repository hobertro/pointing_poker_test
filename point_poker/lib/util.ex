defmodule PointingPoker.Util do
  def random_letter_or_number(num) do
    cond do
      num < 10 -> num + 48
      num < 36 -> num + 55
      num < 62 -> num + 61
    end
  end

  def random_id(size) do
    Enum.reduce(0..(size - 1), [], fn _, acc ->
      [random_letter_or_number(Enum.random(0..61)) | acc]
    end)
    |> to_string
  end
end
