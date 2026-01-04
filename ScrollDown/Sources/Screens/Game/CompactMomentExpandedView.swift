import SwiftUI

struct CompactMomentExpandedView: View {
    let moment: CompactMoment
    let service: GameService

    @StateObject private var viewModel = CompactMomentPbpViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                headerSection
                pbpSection
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.bottom, Layout.bottomPadding)
        }
        .background(GameTheme.background)
        .navigationTitle("Play-by-play")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(moment: moment, service: service)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Layout.textSpacing) {
            Text(moment.displayTitle)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            if let description = moment.description, description != moment.displayTitle {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: Layout.detailSpacing) {
                if let timeLabel = moment.timeLabel {
                    Label(timeLabel, systemImage: "clock")
                }
                if let team = moment.teamAbbreviation {
                    Label(team, systemImage: "sportscourt")
                }
                if let player = moment.playerName {
                    Label(player, systemImage: "person.fill")
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
        }
    }

    private var pbpSection: some View {
        VStack(alignment: .leading, spacing: Layout.cardSpacing) {
            Text("Play-by-play slice")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: Layout.textSpacing) {
                    Text("Unable to load play-by-play.")
                        .font(.subheadline.weight(.semibold))
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        Task { await viewModel.load(moment: moment, service: service) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if viewModel.events.isEmpty {
                EmptySectionView(text: "No play-by-play data available for this moment.")
            } else {
                VStack(spacing: Layout.rowSpacing) {
                    ForEach(viewModel.events) { event in
                        PbpEventRow(event: event)
                    }
                }
            }
        }
    }
}

private struct PbpEventRow: View {
    let event: PbpEvent

    var body: some View {
        HStack(alignment: .top, spacing: Layout.rowContentSpacing) {
            VStack(alignment: .leading, spacing: Layout.textSpacing) {
                Text(event.displayDescription)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                if let player = event.playerName {
                    Text(player)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let team = event.team {
                    Text(team)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if let timeLabel = event.timeLabel {
                Text(timeLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(Layout.rowPadding)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .stroke(Color(.systemGray5), lineWidth: Layout.borderWidth)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Play-by-play event")
        .accessibilityValue(event.displayDescription)
    }
}

private extension PbpEvent {
    var displayDescription: String {
        if let description, !description.isEmpty {
            return description
        }
        if let eventType {
            return eventType.replacingOccurrences(of: "_", with: " ").capitalized
        }
        return "Play update"
    }

    var timeLabel: String? {
        var parts: [String] = []
        if let period {
            parts.append("Q\(period)")
        }
        if let gameClock {
            parts.append(gameClock)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }
}

private enum Layout {
    static let sectionSpacing: CGFloat = 20
    static let textSpacing: CGFloat = 6
    static let detailSpacing: CGFloat = 12
    static let cardSpacing: CGFloat = 12
    static let rowSpacing: CGFloat = 10
    static let rowContentSpacing: CGFloat = 12
    static let rowPadding: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 1
    static let horizontalPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 24
}

#Preview {
    let moment = PreviewFixtures.highlightsHeavyGame.compactMoments?.first
        ?? CompactMoment(
            id: .int(1),
            period: 1,
            gameClock: "12:00",
            title: "Opening tip",
            description: "Opening tip sets the tempo early.",
            teamAbbreviation: "BOS",
            playerName: "Jayson Tatum"
        )

    NavigationStack {
        CompactMomentExpandedView(moment: moment, service: MockGameService())
    }
    .preferredColorScheme(.dark)
}
