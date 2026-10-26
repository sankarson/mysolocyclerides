import Foundation

struct Book: Identifiable, Hashable {
    let id: String          // folder on the site, e.g. "greece"
    let country: String
    let year: String
    let dates: String
    let pagePrefix: String  // e.g. "Greece-Page-"
    let pageCount: Int

    static let siteURL = URL(string: "https://cycling.sankarson.in")!

    var title: String { "\(country) \(year)" }
    var coverURL: URL { Self.siteURL.appending(path: "webp/\(id)-cover.webp") }

    /// Page 0 is the cover; every later page is a two-page spread.
    func label(for page: Int) -> String {
        page == 0 ? "Cover" : "Page \(page * 2 - 1)-\(page * 2)"
    }

    func pageURL(_ page: Int, width: Int = 1600) -> URL {
        Self.siteURL.appending(path: "\(id)/webp/\(pagePrefix)\(page)-\(width).webp")
    }

    func thumbnailURL(_ page: Int) -> URL {
        Self.siteURL.appending(path: "\(id)/thumbnails/\(pagePrefix)\(page).webp")
    }

    static let all: [Book] = [
        Book(id: "greece", country: "Greece", year: "2025", dates: "October 25 to November 11, 2025", pagePrefix: "Greece-Page-", pageCount: 62),
        Book(id: "spain", country: "Spain", year: "2025", dates: "May 25 to June 30, 2025", pagePrefix: "Spain-Page-", pageCount: 62),
        Book(id: "v4", country: "Visegrad 4", year: "2024", dates: "10-May to 15-Jun, 2024", pagePrefix: "V4-Page-", pageCount: 62),
        Book(id: "japan", country: "Japan", year: "2023", dates: "24-Mar to 21-Apr, 2023", pagePrefix: "Japan-Page-", pageCount: 62),
    ]
}
