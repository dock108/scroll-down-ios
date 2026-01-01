import SwiftUI

/// Game detail view showing full game information
struct GameDetailView: View {
    @EnvironmentObject var appConfig: AppConfig
    let gameId: Int
    
    @State private var gameDetail: GameDetailResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if let detail = gameDetail {
                gameContentView(detail)
            }
        }
        .navigationTitle("Game Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadGame()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading game...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Error")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await loadGame() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func gameContentView(_ detail: GameDetailResponse) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Game header
                gameHeaderCard(detail.game)
                
                // Score card
                scoreCard(detail.game)
                
                // Team stats section
                if !detail.teamStats.isEmpty {
                    teamStatsSection(detail.teamStats)
                }
                
                // Player stats section
                if !detail.playerStats.isEmpty {
                    playerStatsSection(detail.playerStats)
                }
                
                // Odds section
                if !detail.odds.isEmpty {
                    oddsSection(detail.odds)
                }
                
                // Social posts section
                if !detail.socialPosts.isEmpty {
                    socialPostsSection(detail.socialPosts)
                }
                
                // Play-by-play section
                if !detail.plays.isEmpty {
                    playsSection(detail.plays)
                }
            }
            .padding()
        }
    }
    
    private func gameHeaderCard(_ game: Game) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(game.leagueCode)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text(game.status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let date = game.parsedGameDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func scoreCard(_ game: Game) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack {
                    Text(game.awayTeam)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    if let score = game.awayScore {
                        Text("\(score)")
                            .font(.system(size: 48, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text("@")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack {
                    Text(game.homeTeam)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    if let score = game.homeScore {
                        Text("\(score)")
                            .font(.system(size: 48, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func teamStatsSection(_ stats: [TeamStat]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Team Stats", icon: "chart.bar.fill")
            
            ForEach(stats) { stat in
                VStack(alignment: .leading, spacing: 4) {
                    Text(stat.team)
                        .font(.subheadline.weight(.medium))
                    Text(stat.isHome ? "Home" : "Away")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private func playerStatsSection(_ stats: [PlayerStat]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Player Stats", icon: "person.fill")
            
            ForEach(stats) { stat in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.playerName)
                            .font(.subheadline.weight(.medium))
                        Text(stat.team)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let pts = stat.points {
                        statBadge("\(pts)", label: "PTS")
                    }
                    if let reb = stat.rebounds {
                        statBadge("\(reb)", label: "REB")
                    }
                    if let ast = stat.assists {
                        statBadge("\(ast)", label: "AST")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private func oddsSection(_ odds: [OddsEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Odds", icon: "dollarsign.circle.fill")
            
            ForEach(odds) { entry in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.book)
                            .font(.subheadline.weight(.medium))
                        Text(entry.marketType.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let line = entry.line {
                        Text(line >= 0 ? "+\(line, specifier: "%.1f")" : "\(line, specifier: "%.1f")")
                            .font(.subheadline.weight(.medium))
                    }
                    
                    if let price = entry.price {
                        Text(price >= 0 ? "+\(Int(price))" : "\(Int(price))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private func socialPostsSection(_ posts: [SocialPostEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Social Posts (\(posts.count))", icon: "bubble.left.and.bubble.right.fill")
            
            ForEach(posts) { post in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if let handle = post.sourceHandle {
                            Text("@\(handle)")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        if post.hasVideo {
                            Image(systemName: "video.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let text = post.tweetText {
                        Text(text)
                            .font(.subheadline)
                            .lineLimit(3)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private func playsSection(_ plays: [PlayEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Plays (First 5)", icon: "list.bullet")
            
            ForEach(plays.prefix(5)) { play in
                HStack(alignment: .top, spacing: 12) {
                    VStack {
                        Text("Q\(play.quarter ?? 0)")
                            .font(.caption2.weight(.medium))
                        Text(play.gameClock ?? "--")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if let desc = play.description {
                            Text(desc)
                                .font(.caption)
                        }
                        if let player = play.playerName {
                            Text(player)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let home = play.homeScore, let away = play.awayScore {
                        Text("\(away)-\(home)")
                            .font(.caption.weight(.medium))
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
        }
    }
    
    private func statBadge(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption.weight(.bold))
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 40)
    }
    
    // MARK: - Data Loading
    
    private func loadGame() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let service = appConfig.gameService
            gameDetail = try await service.fetchGame(id: gameId)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(gameId: 12345)
    }
    .environmentObject(AppConfig.shared)
}

