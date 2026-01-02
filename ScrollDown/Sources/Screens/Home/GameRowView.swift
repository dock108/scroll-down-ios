import SwiftUI

/// Row view for displaying a game summary in a list
struct GameRowView: View {
    let game: GameSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // League and date
            HStack {
                Text(game.leagueCode)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(leagueColor.opacity(0.15))
                    .foregroundColor(leagueColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Spacer()
                
                Text(game.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Teams and score
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(game.awayTeam)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        if let score = game.awayScore {
                            Text("\(score)")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(awayWon ? .primary : .secondary)
                        }
                    }
                    
                    HStack {
                        Text(game.homeTeam)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        if let score = game.homeScore {
                            Text("\(score)")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(homeWon ? .primary : .secondary)
                        }
                    }
                }
            }
            
            // Data availability indicators
            HStack(spacing: 8) {
                dataIndicator("Box", available: game.hasBoxscore ?? false)
                dataIndicator("Stats", available: game.hasPlayerStats ?? false)
                dataIndicator("Odds", available: game.hasOdds ?? false)
                dataIndicator("Social", available: game.hasSocial ?? false)
                dataIndicator("PBP", available: game.hasPbp ?? false)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helpers
    
    private var leagueColor: Color {
        switch game.leagueCode {
        case "NBA": return .orange
        case "NFL": return .blue
        case "MLB": return .red
        case "NHL": return .purple
        case "NCAAB": return .green
        case "NCAAF": return .teal
        default: return .gray
        }
    }
    
    private var homeWon: Bool {
        guard let home = game.homeScore, let away = game.awayScore else { return false }
        return home > away
    }
    
    private var awayWon: Bool {
        guard let home = game.homeScore, let away = game.awayScore else { return false }
        return away > home
    }
    
    private func dataIndicator(_ label: String, available: Bool) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(available ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption2)
                .foregroundColor(available ? .secondary : .secondary.opacity(0.5))
        }
    }
}

#Preview {
    List {
        GameRowView(game: GameSummary(
            id: 12345,
            leagueCode: "NBA",
            gameDate: "2026-01-01T19:30:00-05:00",
            homeTeam: "Boston Celtics",
            awayTeam: "Los Angeles Lakers",
            homeScore: 112,
            awayScore: 108,
            hasBoxscore: true,
            hasPlayerStats: true,
            hasOdds: true,
            hasSocial: true,
            hasPbp: true,
            playCount: 482,
            socialPostCount: 24,
            hasRequiredData: true,
            scrapeVersion: 2,
            lastScrapedAt: "2026-01-02T03:15:00Z"
        ))
    }
}


