import Foundation

extension PlaylistDataDTO {
    public static func createPlaylist(named title: String? = nil) -> PlaylistDataDTO {
        .init(uuid: UUID(), title: title ?? "New Playlist", isEditable: true, collectionType: .user)
    }
}

extension PlaylistDataDTO {
    public func count() -> Int { elements.count }

    public func contains(index: Int) -> Bool {
        elements.indices.contains(index)
    }

    public func index(of url: URL) -> Int? {
        elements.firstIndex(where: { $0.url == url })
    }

    public func indexes(of urls: [URL]) -> IndexSet {
        var indexSet = IndexSet()

        for url in urls {
            if let index = index(of: url) {
                indexSet.insert(index)
            }
        }

        return indexSet
    }

    public func elements(for rows: IndexSet) -> [PlaylistElement] {
        var out = [PlaylistElement]()

        for row in rows where contains(index: row) {
            out.append(elements[row])
        }

        return out
    }

    public func element(at index: Int) -> PlaylistElement? {
        guard contains(index: index) else { return nil }
        return elements[index]
    }

    public func contains(url: URL) -> Bool {
        elements.contains(where: { $0.mafDescription.url == url })
    }

    public func filterContains(elements: [PlaylistElement]) -> [PlaylistElement] {
        elements.filter {
            !contains(url: $0.url)
        }
    }

    public func nextIndex(after item: PlaylistElement) -> Int? {
        guard let i = elements.firstIndex(of: item),
              contains(index: i + 1)
        else {
            return nil
        }

        return i + 1
    }

    /// Build [URL: Date] mapping of file URLs to their cached modification dates
    /// for use with ``FileModificationObserver``.
    public var trackedFileModificationDates: [URL: Date] {
        var result = [URL: Date]()
        for element in elements {
            if let date = element.mafDescription.urlProperties.modificationDate {
                result[element.url] = date
            }
        }
        return result
    }
}
