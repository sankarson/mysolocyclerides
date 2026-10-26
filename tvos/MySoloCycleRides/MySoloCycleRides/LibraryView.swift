import SwiftUI

struct LibraryView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 48), count: 4)
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
                VStack(alignment: .leading, spacing: 40) {
                    Text("Since 2022, I've been riding solo across countries for about 40 days at a time: no route, no hotels, and only as much as fits in my panniers.")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: columns, spacing: 48) {
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
                .padding(.horizontal, 80)
                .padding(.vertical, 40)
            }
            .navigationTitle("My Solo Cycle Rides")
            .navigationDestination(for: Book.self) { PhotobookView(book: $0) }
        }
    }
}

private struct BookCard: View {
    let book: Book
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: book.coverURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                case .failure: Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
                default: ProgressView()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .scaleEffect(isFocused ? 1.08 : 1)
            .shadow(color: .black.opacity(isFocused ? 0.4 : 0), radius: 20, y: 12)
            .animation(.easeOut(duration: 0.15), value: isFocused)

            Text(book.title).font(.headline)
        }
    }
}
