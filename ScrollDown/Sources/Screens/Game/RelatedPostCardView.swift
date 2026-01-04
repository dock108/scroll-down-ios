import SwiftUI

struct RelatedPostCardView: View {
    @Environment(\.openURL) private var openURL
    let post: RelatedPost
    let isRevealed: Bool
    let onReveal: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            header
            mediaView
            Text(post.text ?? "Post")
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            if isRevealed, let url = URL(string: post.postUrl) {
                Button("Open Post") {
                    openURL(url)
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(GameTheme.accentColor)
                .buttonStyle(.plain)
            }
        }
        .blur(radius: shouldBlur ? Layout.blurRadius : 0)
        .animation(.easeInOut(duration: 0.2), value: shouldBlur)
        .overlay(blurOverlay)
        .padding(Layout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GameTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .stroke(GameTheme.cardBorder, lineWidth: Layout.borderWidth)
        )
        .shadow(
            color: GameTheme.cardShadow,
            radius: Layout.shadowRadius,
            x: 0,
            y: Layout.shadowYOffset
        )
        .contentShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
        .onTapGesture {
            if shouldBlur {
                onReveal()
            }
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }

    private var header: some View {
        HStack {
            Text("Related")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            Spacer()
            VStack(alignment: .trailing, spacing: Layout.metaSpacing) {
                if let handle = post.sourceHandle {
                    Text("@\(handle)")
                        .font(.caption.weight(.medium))
                        .foregroundColor(GameTheme.accentColor)
                }
                Text(formattedTimestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var mediaView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Layout.mediaCornerRadius)
                .fill(Color(.systemGray6))
                .frame(height: Layout.mediaHeight)
            if let imageURL = post.imageUrl, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    mediaPlaceholder
                }
                .frame(height: Layout.mediaHeight)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: Layout.mediaCornerRadius))
            } else {
                mediaPlaceholder
            }
        }
    }

    private var mediaPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Layout.mediaCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray6), Color(.systemGray5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: Layout.mediaHeight)
            VStack(spacing: Layout.placeholderSpacing) {
                Image(systemName: "newspaper")
                    .font(.system(size: Layout.iconSize))
                    .foregroundColor(.secondary)
                Text("Preview unavailable in mock mode")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, Layout.placeholderPadding)
        }
    }

    private var blurOverlay: some View {
        Group {
            if shouldBlur {
                ZStack {
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .fill(Color.black.opacity(Layout.blurOverlayOpacity))
                    VStack(spacing: Layout.overlaySpacing) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: Layout.overlayIconSize))
                            .foregroundColor(.white)
                        Text("Tap to reveal")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private var shouldBlur: Bool {
        post.containsScore && !isRevealed
    }

    private var formattedTimestamp: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let parsedDate = formatter.date(from: post.postedAt)
            ?? ISO8601DateFormatter().date(from: post.postedAt)
        if let parsedDate {
            return parsedDate.formatted(date: .abbreviated, time: .shortened)
        }
        return post.postedAt
    }

    private var accessibilityLabel: String {
        if shouldBlur {
            return "Related post hidden"
        }
        return "Related post from \(post.sourceHandle ?? "source")"
    }

    private var accessibilityHint: String {
        shouldBlur ? "Tap to reveal the post" : "Double tap to open the post"
    }
}

private enum Layout {
    static let spacing: CGFloat = 12
    static let padding: CGFloat = 14
    static let cornerRadius: CGFloat = 16
    static let borderWidth: CGFloat = 1
    static let mediaHeight: CGFloat = 160
    static let mediaCornerRadius: CGFloat = 12
    static let iconSize: CGFloat = 32
    static let placeholderSpacing: CGFloat = 6
    static let placeholderPadding: CGFloat = 12
    static let metaSpacing: CGFloat = 2
    static let shadowRadius: CGFloat = 10
    static let shadowYOffset: CGFloat = 4
    static let blurRadius: CGFloat = 16
    static let blurOverlayOpacity: Double = 0.35
    static let overlaySpacing: CGFloat = 8
    static let overlayIconSize: CGFloat = 24
}

#Preview {
    RelatedPostCardView(
        post: RelatedPost(
            id: 201,
            postUrl: "https://x.com/nba/status/1874567890123456801",
            postedAt: "2026-01-01T19:10:00Z",
            containsScore: true,
            text: "Final: Celtics 112, Lakers 108. Instant reactions roll in.",
            imageUrl: nil,
            sourceHandle: "NBA"
        ),
        isRevealed: false,
        onReveal: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
