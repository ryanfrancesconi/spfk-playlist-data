import AppKit
import SPFKBase

extension PlaylistDataDTO {
    public mutating func cache(cgImage: CGImage, for url: URL) throws {
        guard let index = index(of: url) else {
            throw NSError(file: #file, function: #function, description: "invalid url passed to function")
        }

        elements[index].mafDescription.imageDescription.cgImage = cgImage
    }

    public mutating func removeImage(at index: Int) throws {
        guard elements.indices.contains(index) else {
            throw NSError(description: "invalid index")
        }

        elements[index].mafDescription.imageDescription.cgImage = nil
    }
}

extension PlaylistDataDTO {
    /// Refreshes security-scoped bookmark data for every element.
    public mutating func updateBookmarks() {
        for i in 0 ..< elements.count {
            do {
                try elements[i].updateBookmark()
            } catch {
                Log.error("Error updating bookmark data for \(elements[i].filename)", error)
            }
        }
    }
}
