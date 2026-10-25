import SwiftUI

struct LibraryView: View {
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
    @State private var path: [Book] = {
        #if DEBUG
        // `-openBook spain` (launch argument) jumps straight into a book for UI checks.
        if let id = UserDefaults.standard.string(forKey: "openBook"),
           let book = Book.all.first(where: { $0.id == id }) { return [book] }
        #endif
        return []
    }()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Since 2022, I've been riding solo across countries for about 40 days at a time: no route, no hotels, and only as much as fits in my panniers.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Book.all) { book in
                            NavigationLink(value: book) {
                                BookCard(book: book)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Italy 2022 and UK 2026 photobooks are coming soon.")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                .padding()
            }
            .navigationTitle("My Solo Cycle Rides")
            .navigationDestination(for: Book.self) { PhotobookView(book: $0) }
        }
    }
}

private struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: book.coverURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                case .failure: Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
                default: ProgressView()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 160)

            Text(book.title).font(.headline)
        }
    }
}
