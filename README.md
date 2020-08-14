# EpubCoverExtractor

[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fzelazna%2Fepub_cover_extractor%2Fbadge&style=for-the-badge)](https://actions-badge.atrox.dev/zelazna/epub_cover_extractor/goto)

A tool for getting the ebooks covers, the projet is WIP,
contributions are welcome.

## Installation

Add `epub_cover_extractor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:epub_cover_extractor, "~> 0.1.0"}
  ]
end
```

## Documentation

The project documentation can be found [here](https://hexdocs.pm/epub_cover_extractor/api-reference.html) on Hex

### Quick Start

```elixir

{:ok, binary} = EpubCoverExtractor.get_cover("book.epub")
{:ok,
<<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73,
  72, 68, 82, 0, 0, 5, 130, 0, 0, 8, 202, 8, 6, 0, 0,
  0, 43, 176, 122, 217, 0, 0, 0, 9, 112, 72, 89, 115,
  0, 0, 14, 196, 0, 0, 14...>>}
File.write("cover.png", binary)
```
