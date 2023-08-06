import Foundation

enum Items: String, CaseIterable {
    case add_track = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

enum Events: String, CaseIterable {
    case open = "open"
    case close = "close"
    case click = "click"
}

