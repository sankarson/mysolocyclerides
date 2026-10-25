import SwiftUI

struct PhotobookView: View {
    let book: Book
    @State private var page = 0
    @State private var position: Int? = 0
    @State private var chromeShown = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// In landscape the page fills the screen; a tap brings the bars back.
    private var immersive: Bool { verticalSizeClass == .compact && !chromeShown }

    var body: some View {
        ZStack {
            // Sits behind the safe areas too, so no white shows around the page.
            (immersive ? Color.black : Color(.systemBackground)).ignoresSafeArea()

            VStack(spacing: 0) {
            // A scroll-based pager rather than TabView(.page): that one is a UICollectionView
            // that insets itself by the safe area and can't be made edge to edge.
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<book.pageCount, id: \.self) { index in
                        PageView(url: book.pageURL(index)) {
                            if verticalSizeClass == .compact {
                                withAnimation { chromeShown.toggle() }
                            }
                        }
                        .containerRelativeFrame([.horizontal, .vertical])
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $position)
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: immersive ? .all : [])
            .onChange(of: position) { _, new in if let new { page = new } }
            .onChange(of: page) { _, new in if position != new { position = new } }

            if !immersive {
                ThumbnailStrip(book: book, page: $page)
                    .transition(.move(edge: .bottom))
            }
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(immersive ? .hidden : .automatic, for: .navigationBar)
        .statusBarHidden(immersive)
        .persistentSystemOverlays(immersive ? .hidden : .automatic)
        .onChange(of: verticalSizeClass) { _, _ in chromeShown = false }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(book.title).font(.headline)
                    Text("\(book.label(for: page)) · \(book.dates)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct PageView: View {
    let url: URL
    var onTap: () -> Void = {}
    @State private var scale: CGFloat = 1
    @State private var baseScale: CGFloat = 1

    var body: some View {
        GeometryReader { geo in
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    // Fit the whole page to the available space (re-evaluated on rotation),
                    // then scale the frame up when zoomed so the ScrollView can pan it.
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        image.resizable().scaledToFit()
                            .frame(width: geo.size.width * scale, height: geo.size.height * scale)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .gesture(
                        MagnifyGesture()
                            .onChanged { scale = min(max(baseScale * $0.magnification, 1), 4) }
                            .onEnded { _ in baseScale = scale }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation { scale = scale > 1 ? 1 : 2.5; baseScale = scale }
                    }
                    .onTapGesture(perform: onTap)
                case .failure:
                    Label("Couldn't load page", systemImage: "wifi.slash")
                        .foregroundStyle(.secondary)
                        .frame(width: geo.size.width, height: geo.size.height)
                default:
                    ProgressView().frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
    }
}

private struct ThumbnailStrip: View {
    let book: Book
    @Binding var page: Int

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(0..<book.pageCount, id: \.self) { index in
                        Button { withAnimation { page = index } } label: {
                            VStack(spacing: 2) {
                                AsyncImage(url: book.thumbnailURL(index)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 84, height: 56)
                                .overlay(RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.accentColor, lineWidth: index == page ? 2 : 0))
                                Text(book.label(for: index)).font(.system(size: 9)).foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .id(index)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(.bar)
            .onChange(of: page) { _, new in withAnimation { proxy.scrollTo(new, anchor: .center) } }
        }
    }
}
