import SwiftUI

/// Full-screen page viewer: swipe or press left/right on the Siri Remote to turn pages.
struct PhotobookView: View {
    let book: Book
    @State private var page = 0
    @State private var labelVisible = true
    @FocusState private var focused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: book.pageURL(page, width: 2400)) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                case .failure: Label("Couldn't load page", systemImage: "wifi.slash").foregroundStyle(.secondary)
                default: ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .id(page)

            if labelVisible {
                Text("\(book.title) · \(book.label(for: page))")
                    .font(.callout)
                    .padding(.horizontal, 24).padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 40)
                    .transition(.opacity)
            }
        }
        .focusable()
        .focused($focused)
        .onAppear { focused = true; flashLabel() }
        .onMoveCommand { direction in
            switch direction {
            case .left: turn(-1)
            case .right: turn(1)
            default: break
            }
        }
        .onPlayPauseCommand { withAnimation { labelVisible.toggle() } }
        .task(id: page) { await prefetch(around: page) }
    }

    private func turn(_ delta: Int) {
        let next = page + delta
        guard (0..<book.pageCount).contains(next) else { return }
        page = next
        flashLabel()
    }

    private func flashLabel() {
        withAnimation { labelVisible = true }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation { labelVisible = false }
        }
    }

    /// Warm the URL cache for neighbouring pages so turning is instant.
    private func prefetch(around index: Int) async {
        for i in [index + 1, index - 1, index + 2] where (0..<book.pageCount).contains(i) {
            _ = try? await URLSession.shared.data(from: book.pageURL(i, width: 2400))
        }
    }
}
