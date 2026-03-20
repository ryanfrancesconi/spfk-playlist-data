import AppKit
import SPFKBase
import SPFKUtils

extension Playlist {
    public mutating func update(all newData: [PlaylistElement]) {
        elements = newData

        updateSortIndexes()
    }

    public mutating func update(element: PlaylistElement, isDirty: Bool) throws -> Int {
        for i in 0 ..< elements.count where elements[i].url == element.url {
            try update(element: element, at: i, isDirty: isDirty)
            return i
        }

        throw NSError(file: #file, function: #function, description: "Failed to find element in table data")
    }

    public mutating func update(element: PlaylistElement, at index: Int, isDirty: Bool) throws {
        guard contains(index: index) else {
            throw NSError(description: "invalid row \(index)")
        }

        // don't update if the urls don't match
        assert(elements[index] == element)

        let existing = elements[index]

        elements[index] = element
        elements[index].sortIndex = index

        if isDirty {
            // Only mark dirty if saveable content actually changed.
            // Compare metadata excluding imageDescription (whose thumbnail PNG
            // bytes are non-deterministic across re-encodes). Image changes are
            // tracked via the .image flag on the incoming element.
            let metadataChanged = !existing.mafDescription.isEqualExcludingImage(to: element.mafDescription)
            let colorChanged = existing.hexColor != element.hexColor

            if metadataChanged || colorChanged {
                elements[index].dirtyFlags.insert(.metadata)
            }

            // Carry over image, xmp, and markers flags from the incoming element
            elements[index].dirtyFlags.formUnion(element.dirtyFlags.intersection([.image, .xmp, .markers]))
        } else {
            // Caller explicitly clearing dirty (e.g. after save) — always honor
            elements[index].dirtyFlags = []
        }
    }

    public mutating func insert(
        element: PlaylistElement,
        at row: Int
    ) throws -> IndexSet {
        try insert(elements: [element], at: row)
    }

    public mutating func insert(
        elements newRows: [PlaylistElement],
        at row: Int,
        removeDuplicates: Bool = false
    ) throws -> IndexSet {
        guard newRows.isNotEmpty else {
            throw NSError(description: "No elements are passed in")
        }

        var newRows = newRows

        if removeDuplicates {
            newRows = filterContains(elements: newRows)

            guard newRows.isNotEmpty else {
                throw NSError(description: "No new elements were passed in")
            }
        }

        var previousData = elements
        previousData.insert(contentsOf: newRows, at: row)
        update(all: previousData)

        return IndexSet(integersIn: row ... row + newRows.count - 1)
    }

    /// Moves elements at the given indexes to a new position, consolidating selection at the target row.
    /// - Returns: The new `IndexSet` covering the moved elements, or `nil` if `indexes` is empty.
    public mutating func move(
        indexes: IndexSet,
        to row: Int
    ) -> IndexSet? {
        guard indexes.isNotEmpty else { return nil }

        guard let first = indexes.first else {
            Log.error("Failed to generate a valid range from indexes.", indexes)
            return nil
        }

        var newData = elements

        var dataToMove = [PlaylistElement]()

        for index in indexes {
            dataToMove.append(newData[index])
        }

        newData.remove(atOffsets: indexes)

        var targetRow = row

        if first <= row {
            targetRow -= dataToMove.count
        }

        targetRow = targetRow.clamped(to: 0 ... newData.count)

        if targetRow >= newData.count {
            newData.append(contentsOf: dataToMove)

        } else {
            newData.insert(contentsOf: dataToMove, at: targetRow)
        }

        update(all: newData)

        return IndexSet(integersIn: targetRow ... targetRow + dataToMove.count - 1)
    }

    public mutating func remove(indexes: IndexSet) {
        if indexes.count == elements.count {
            removeAll()
            return
        }

        elements.remove(atOffsets: indexes)
        updateSortIndexes()
    }

    public mutating func removeAll() {
        elements.removeAll()
    }
}
