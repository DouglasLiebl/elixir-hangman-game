defmodule HangmanGame do
  defp file_read() do
    File.stream!("words.txt", [:read])
    |> Enum.map(&trim_and_upcase/1) |> Enum.to_list()
  end

  defp trim_and_upcase(word) do
    word |> String.trim() |> String.upcase()
  end

  def game() do
    word = get_random_word()
    dashed = word |> length() |> build_dashed_lines()
    IO.puts("Voce tem 5 chances para adivinhar a palavra: \n#{dashed}")
    exec(word, dashed, 0)
  end

  defp exec([], [], 4), do: IO.puts("Quantidade de erros atingida, voce perdeu.")
  defp exec(word, dashed, error) do
    letter = IO.gets("Digite uma letra: ") |> String.trim() |> String.upcase()

    cond do
      error == 4 -> IO.puts("Quantidade de erros atingida, voce perdeu.")
      is_used?(letter, dashed) ->
        IO.puts("Letra ja utilizada.")
        exec(word, dashed, error)
      is_wrong?(letter, word) ->
        IO.puts("Letra incorreta")
        exec(word, dashed, error + 1)
      true ->
        dashed_updated = compare(letter, word, dashed)
        IO.puts(dashed_updated)

        if validator(dashed_updated) == word do
          IO.puts("Voce acertou, a palavra era: #{dashed_updated}")
        else
          exec(word, dashed_updated, error)
        end
    end
  end

  defp validator([]), do: []
  defp validator([head | tail]) do
    [String.trim(head) | validator(tail)]
  end

  defp get_random_word() do
    words = file_read()
    value = Enum.random(0..(length(words) - 1))
    get(value, words, 0)
  end

  defp get(0, [head | _tail], _count), do: head |> String.codepoints()
  defp get(value, [head | tail], count) do
    if value == count do
      head |> String.codepoints()
    else
      get(value, tail, count + 1)
    end
  end

  defp build_dashed_lines(0), do: []
  defp build_dashed_lines(word_length) do
    ["_ " | build_dashed_lines((word_length - 1))]
  end



  defp compare(_letter, [], []), do: []
  defp compare(letter, [head | tail], dashed) do
    if letter == head do
      ["#{letter} " | compare(letter, tail, tl(dashed))]
    else
      cond do
        hd(dashed) != "_ " -> [hd(dashed) | compare(letter, tail, tl(dashed))]
        true -> ["_ " | compare(letter, tail, tl(dashed))]
      end
    end
  end

  defp is_wrong?(letter, list) do
    if letter in list, do: false, else: true
  end
  defp is_used?(letter, dashed) do
    if "#{letter} " in dashed, do: true, else: false
  end

end

HangmanGame.game()
