defmodule EpubCoverExtractor do
  import SweetXml

  @cover_path 'OEBPS/assets/cover.png'

  @moduledoc """
  Documentation for EpubCoverExtractor.
  TODO
  """

  @doc """
  TODO

  ## Examples

      iex> EpubCoverExtractor.get_cover('book.epub')
      {:ok,
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73,
        72, 68, 82, 0, 0, 5, 130, 0, 0, 8, 202, 8, 6, 0, 0,
        0, 43, 176, 122, 217, 0, 0, 0, 9, 112, 72, 89, 115,
        0, 0, 14, 196, 0, 0, 14, ...>>}
  """
  def get_cover(path) do
    {:ok, handle} = :zip.zip_open(path)

    {:ok, results} =
      case get_cover_from_manifest(handle) do
        {:ok, results} -> {:ok, results}
        {:error, _reason} -> get_cover_by_filename(handle)
      end

    Enum.each(['OEBPS', 'META-INF'], &File.rm_rf/1)

    results
  end

  def get_cover_from_manifest(handle) do
    with {:ok, file} <- :zip.zip_get('META-INF/container.xml', handle),
         root_file <- File.read!(file),
         {:ok, content_file} <-
           root_file
           |> xpath(~x"//rootfile/@full-path")
           |> :zip.zip_get(handle),
         cover_path <-
           File.read!(content_file)
           |> xpath(~x"//manifest/item[@id='cover-image']/@href"),
         full_path <- 'OEBPS/' ++ cover_path do
      {:ok, get_cover_by_filename(handle, full_path)}
    else
      err -> {:error, err}
    end
  end

  def get_cover_by_filename(handle, cover_path \\ @cover_path) do
    :zip.zip_get(cover_path, handle)

    case File.read(cover_path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end
end
