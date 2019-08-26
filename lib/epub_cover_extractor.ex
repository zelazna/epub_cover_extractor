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
    to_charlist(path) |> get_cover
  end

  def get_cover(path) do
    handle =
      case :zip.zip_open(path, [:memory]) do
        {:ok, handle} -> handle
        err -> err
      end

    results =
      case get_cover_from_manifest(handle) do
        {:error, _reason} -> get_cover_by_filename(handle)
        results -> results
      end

    close_zip(handle)
    results
  end

  defp get_cover_from_manifest({:error, _reason} = err), do: err

  defp get_cover_from_manifest(handle) do
    with {:ok, {_file, xml}} <- :zip.zip_get('META-INF/container.xml', handle),
         {:ok, {_file, xml}} <-
           xml
           |> xpath(~x"//rootfile/@full-path")
           |> :zip.zip_get(handle),
         cover_path <-
           xml |> xpath(~x"//manifest/item[@id='cover-image']/@href"),
         full_path <- 'OEBPS/' ++ cover_path do
      get_cover_by_filename(handle, full_path)
    else
      err -> err
    end
  end

  defp get_cover_by_filename(handle, cover_path \\ @cover_path)

  defp get_cover_by_filename({:error, _reason} = err, _path), do: err

  defp get_cover_by_filename(handle, cover_path) do
    case :zip.zip_get(cover_path, handle) do
      {:ok, {_file, binary}} -> {:ok, binary}
      err -> err
    end
  end

  defp close_zip({:error, reason}), do: reason

  defp close_zip(handle), do: :zip.zip_close(handle)
end
