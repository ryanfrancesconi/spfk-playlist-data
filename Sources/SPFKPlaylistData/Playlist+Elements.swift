import AppKit
import SPFKBase

extension Playlist {
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
