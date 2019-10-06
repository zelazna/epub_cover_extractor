defmodule EpubCoverExtractorTest do
  use ExUnit.Case

  @book_path "test/fixtures/books/"
  @img_path "test/fixtures/images/"

  test "raise an error if the path is not a string" do
    assert_raise FunctionClauseError, fn ->
      EpubCoverExtractor.get_cover(123)
    end
  end

  test "raise an error if the book doesn't exists" do
    assert_raise ArgumentError, fn ->
      EpubCoverExtractor.get_cover("123")
    end
  end

  test "raise an error if the book has not the right extension" do
    assert_raise ArgumentError, fn ->
      EpubCoverExtractor.get_cover(@img_path <> "cover3.png")
    end
  end

  test "returns all the books covers" do
    assert_cover = fn path -> assert {:ok, bin} = EpubCoverExtractor.get_cover(path) end

    Path.wildcard(@book_path <> "*.epub")
    |> Enum.each(assert_cover)
  end
end
