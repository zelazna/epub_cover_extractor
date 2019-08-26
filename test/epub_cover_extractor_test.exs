defmodule EpubCoverExtractorTest do
  use ExUnit.Case

  test "returns an error if the book doesnt exists" do
    assert EpubCoverExtractor.get_cover('do_not_exists') == {:error, :enoent}
  end

  test "returns the cover" do
    assert EpubCoverExtractor.get_cover('test/resources/books/book.epub') ==
             File.read("test/resources/images/cover.png")

    assert EpubCoverExtractor.get_cover('test/resources/books/book3.epub') ==
             File.read("test/resources/images/cover3.png")
  end

  test "returns the cover with string params" do
    assert EpubCoverExtractor.get_cover("test/resources/books/book.epub") ==
             File.read("test/resources/images/cover.png")
  end
end
