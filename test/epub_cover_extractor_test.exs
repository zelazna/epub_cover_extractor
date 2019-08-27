defmodule EpubCoverExtractorTest do
  use ExUnit.Case

  @book_path "test/resources/books/"
  @img_path "test/resources/images/"

  test "raise an error if the path is not a string" do
    assert_raise FunctionClauseError, fn ->
      EpubCoverExtractor.get_cover(123)
    end
  end

  test "returns an error if the book doesnt exists" do
    assert EpubCoverExtractor.get_cover("do_not_exists") == {:error, :enoent}
  end

  test "returns the cover with a right manifest" do
    assert EpubCoverExtractor.get_cover("#{@book_path}book3.epub") ==
             File.read("#{@img_path}cover3.png")
  end

  test "returns the cover with the cover path" do
    assert EpubCoverExtractor.get_cover("#{@book_path}book.epub") ==
             File.read("#{@img_path}cover.png")
  end
end
