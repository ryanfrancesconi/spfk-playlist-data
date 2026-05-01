import Foundation

extension Playlist {
    public mutating func sort(key: String, direction: Bool) {
        let sortedData = sort(elements, by: key, direction: direction)

        update(all: sortedData)
    }

    public mutating func sort(valueProvider: (PlaylistElement) -> String?, direction: Bool) {
        let sorted = elements.sorted {
            let f1 = valueProvider($0) ?? ""
            let f2 = valueProvider($1) ?? ""
            return f1.standardCompare(with: f2, ascending: direction)
        }
        update(all: sorted)
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
