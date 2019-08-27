defmodule EpubCoverExtractor do
  import SweetXml

  @cover_path 'cover.jpeg'

  @moduledoc """
  Documentation for EpubCoverExtractor.
  Handle the logic of getting the cover from the Epub archive
  """

  @doc """
  Open the EPUB archive and get the ebook cover

  ## Examples
      EpubCoverExtractor.get_cover("donotexist")
      {:error, :enoent}

      {:ok, binary} = EpubCoverExtractor.get_cover("book.epub")
      {:ok,
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73,
        72, 68, 82, 0, 0, 5, 130, 0, 0, 8, 202, 8, 6, 0, 0,
        0, 43, 176, 122, 217, 0, 0, 0, 9, 112, 72, 89, 115,
        0, 0, 14, 196, 0, 0, 14...>>}
      File.write("cover.png", binary)
  """
  def get_cover(path) when is_binary(path) do
    Path.expand(path)
    |> to_charlist()
    |> open_archive()
    |> find_cover_file()
    |> close_archive()
  end

  defp open_archive(path) do
    :zip.zip_open(path, [:memory])
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

  defp find_cover_by_filename({handle, {:error, _}}), do: extract_cover(handle)

  defp find_cover_by_filename({_, {:ok, _} = result}), do: result

  defp extract_cover(handle, cover_path \\ @cover_path) do
    case :zip.zip_get(cover_path, handle) do
      {:ok, {_, binary}} -> {:ok, binary}
      err -> err
    end
  end
end
