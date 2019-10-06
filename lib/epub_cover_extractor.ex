defmodule EpubCoverExtractor do
  import SweetXml

  @cover_paths ['cover.jpeg', 'cover.jpg', 'cover.png']

  @moduledoc """
  Documentation for EpubCoverExtractor.
  Handle the logic of getting the cover from the Epub archive
  """

  @doc """
  Open the EPUB archive and get the ebook cover

  ## Examples
      EpubCoverExtractor.get_cover("doesnotexist")
      {:error, :enoent}

      {:ok, binary} = EpubCoverExtractor.get_cover("book.epub")
      {:ok,
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73,
        72, 68, 82, 0, 0, 5, 130, 0, 0, 8, 202, 8, 6, 0, 0,
        0, 43, 176, 122, 217, 0, 0, 0, 9, 112, 72, 89, 115,
        0, 0, 14, 196, 0, 0, 14...>>}
      File.write("cover.png", binary)
  """
  def get_cover(epub) when is_binary(epub) do
    Path.expand(epub)
    |> check_file()
    |> check_extension()
    |> to_charlist()
    |> open_archive()
    |> find_cover_file()
    |> close_archive()
  end

  defp open_archive(epub) do
    :zip.zip_open(epub, [:memory])
  end

  defp close_archive({:error, _} = err), do: err

  defp close_archive({results, handle}) do
    :zip.zip_close(handle)
    results
  end

  defp find_cover_file({:error, _} = err), do: err

  defp find_cover_file({:ok, handle}) do
    {find_cover_from_manifest(handle) |> find_cover_by_filename(), handle}
  end

  defp find_cover_from_manifest(handle) do
    {:ok, {_, xml}} = :zip.zip_get('META-INF/container.xml', handle)
    {:ok, {_, xml}} = xml |> xpath(~x"//rootfile/@full-path") |> :zip.zip_get(handle)
    cover_path = xml |> xpath(~x"//manifest/item[@id='cover-image']/@href")
    {handle, extract_cover(handle, 'OEBPS/' ++ cover_path)}
  end

  defp find_cover_by_filename({handle, {:error, _}}) do
    Enum.map(@cover_paths, &extract_cover(handle, &1))
    |> Enum.find(fn {res, _} -> res == :ok end)
  end

  defp find_cover_by_filename({_, {:ok, _} = result}), do: result

  defp extract_cover(handle, cover_path) do
    case :zip.zip_get(cover_path, handle) do
      {:ok, {_, binary}} -> {:ok, binary}
      err -> err
    end
  end

  defp check_file(epub) do
    unless File.exists?(epub) do
      raise ArgumentError, "file #{epub} does not exists"
    end

    epub
  end

  defp check_extension(epub) do
    unless epub |> Path.extname() |> String.downcase() == ".epub" do
      raise ArgumentError, "file #{epub} does not have an '.epub' extension"
    end

    epub
  end
end
