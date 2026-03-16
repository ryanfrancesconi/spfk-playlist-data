import Foundation

extension Playlist {
    public mutating func sort(key: String, direction: Bool) {
        let sortedData = sort(elements, by: key, direction: direction)

        update(all: sortedData)
    }

    private func sort(_ data: [PlaylistElement], by field: String, direction: Bool) -> [PlaylistElement] {
        data.sorted {
            let f1 = $0.sortValue(columnTitled: field) ?? ""
            let f2 = $1.sortValue(columnTitled: field) ?? ""

            return f1.standardCompare(with: f2, ascending: direction)
        }
    }

    // TODO: CLAUDE
    // audit Playlist+Sort.swift:21 - keeping PlaylistElement.sortIndex in sync
    public mutating func updateSortIndexes() {
        for i in 0 ..< elements.count {
            elements[i].sortIndex = i
        }
    }
}
