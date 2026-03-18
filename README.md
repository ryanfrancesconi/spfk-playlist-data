# SPFKPlaylistData

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-playlist-data%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanfrancesconi/spfk-playlist-data)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanfrancesconi%2Fspfk-playlist-data%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanfrancesconi/spfk-playlist-data)

Lightweight playlist data types and definitions extracted from [SPFKData](https://github.com/ryanfrancesconi/spfk-data). Depends on [SPFKMetadataBase](https://github.com/ryanfrancesconi/spfk-metadata-base) for metadata types — no TagLib, libsndfile, or C++ dependency.

File I/O operations (parsing audio files into playlist elements, importing, searching) remain in [SPFKData](https://github.com/ryanfrancesconi/spfk-data).

## Requirements

- **Platform:** macOS 14+
- **Swift:** 6.2+

## Types

| Type | Description |
|------|-------------|
| **Playlist** | Playlist container with name, collection type, preset, and ordered elements |
| **PlaylistElement** | Individual playlist entry wrapping audio file metadata, tags, and display values |
| **PlaylistGroup** | Group container holding multiple playlists with sort ordering |
| **CollectionType** | Enum distinguishing system vs. user collections |
| **CollectionPreset** | Enum for built-in playlist presets (system group, search results, favorites, playlists) |
| **AudioFileTableColumn** | Column definitions for playlist table display (file, duration, format, markers, etc.) |
| **PlaylistElementUpdate** | Describes a pending update to a playlist element |
| **PlaylistElementParseResult** | Result type for playlist element parsing operations |

## Installation

```swift
.package(url: "https://github.com/ryanfrancesconi/spfk-playlist-data", from: "0.0.1")
```

```swift
import SPFKPlaylistData
```

## Dependencies

| Package | Description |
|---------|-------------|
| [spfk-metadata-base](https://github.com/ryanfrancesconi/spfk-metadata-base) | Pure metadata data types (no C++ dependency) |
| [spfk-search](https://github.com/ryanfrancesconi/spfk-search) | Search framework |
| [spfk-utils](https://github.com/ryanfrancesconi/spfk-utils) | Foundation utilities and extensions |
