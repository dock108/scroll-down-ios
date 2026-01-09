import Foundation

/// Team info as returned by the /games snapshot endpoint
struct TeamInfo: Codable, Hashable {
    let id: Int
    let name: String
    let abbreviation: String
}

/// Game summary for list views matching the /games snapshot endpoint
struct GameSummary: Codable, Identifiable, Hashable {
    let id: Int
    let league: String
    let startTime: String
    let statusRaw: String?
    let homeTeamInfo: TeamInfo
    let awayTeamInfo: TeamInfo
    let hasPbp: Bool?
    let hasSocial: Bool?
    let lastUpdatedAt: String?
    
    // Legacy fields for mock data compatibility
    let leagueCode: String?
    let gameDate: String?
    let homeTeam: String?
    let awayTeam: String?
    let homeScore: Int?
    let awayScore: Int?
    let hasBoxscore: Bool?
    let hasPlayerStats: Bool?
    let hasOdds: Bool?
    let playCount: Int?
    let socialPostCount: Int?
    let hasRequiredData: Bool?
    let scrapeVersion: Int?
    let lastScrapedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case league
        case startTime = "start_time"
        case statusRaw = "status"
        case homeTeamInfo = "home_team"
        case awayTeamInfo = "away_team"
        case hasPbp = "has_pbp"
        case hasSocial = "has_social"
        case lastUpdatedAt = "last_updated_at"
        // Legacy keys
        case leagueCode = "league_code"
        case gameDate = "game_date"
        case homeTeam = "home_team_name"
        case awayTeam = "away_team_name"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case hasBoxscore = "has_boxscore"
        case hasPlayerStats = "has_player_stats"
        case hasOdds = "has_odds"
        case playCount = "play_count"
        case socialPostCount = "social_post_count"
        case hasRequiredData = "has_required_data"
        case scrapeVersion = "scrape_version"
        case lastScrapedAt = "last_scraped_at"
    }
    
    // Custom decoder to handle both API and mock formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        
        // League: API uses "league", mock uses "league_code"
        if let l = try container.decodeIfPresent(String.self, forKey: .league) {
            league = l
            leagueCode = l
        } else if let lc = try container.decodeIfPresent(String.self, forKey: .leagueCode) {
            league = lc
            leagueCode = lc
        } else {
            league = "Unknown"
            leagueCode = nil
        }
        
        // Time: API uses "start_time", mock uses "game_date"
        if let st = try container.decodeIfPresent(String.self, forKey: .startTime) {
            startTime = st
            gameDate = st
        } else if let gd = try container.decodeIfPresent(String.self, forKey: .gameDate) {
            startTime = gd
            gameDate = gd
        } else {
            startTime = ""
            gameDate = nil
        }
        
        statusRaw = try container.decodeIfPresent(String.self, forKey: .statusRaw)
        
        // Teams: API uses objects, mock might use strings
        if let home = try? container.decode(TeamInfo.self, forKey: .homeTeamInfo) {
            homeTeamInfo = home
            homeTeam = home.name
        } else {
            let homeName = try container.decodeIfPresent(String.self, forKey: .homeTeam) ?? "Home"
            homeTeamInfo = TeamInfo(id: 0, name: homeName, abbreviation: String(homeName.prefix(3)).uppercased())
            homeTeam = homeName
        }
        
        if let away = try? container.decode(TeamInfo.self, forKey: .awayTeamInfo) {
            awayTeamInfo = away
            awayTeam = away.name
        } else {
            let awayName = try container.decodeIfPresent(String.self, forKey: .awayTeam) ?? "Away"
            awayTeamInfo = TeamInfo(id: 0, name: awayName, abbreviation: String(awayName.prefix(3)).uppercased())
            awayTeam = awayName
        }
        
        hasPbp = try container.decodeIfPresent(Bool.self, forKey: .hasPbp)
        hasSocial = try container.decodeIfPresent(Bool.self, forKey: .hasSocial)
        lastUpdatedAt = try container.decodeIfPresent(String.self, forKey: .lastUpdatedAt)
        homeScore = try container.decodeIfPresent(Int.self, forKey: .homeScore)
        awayScore = try container.decodeIfPresent(Int.self, forKey: .awayScore)
        hasBoxscore = try container.decodeIfPresent(Bool.self, forKey: .hasBoxscore)
        hasPlayerStats = try container.decodeIfPresent(Bool.self, forKey: .hasPlayerStats)
        hasOdds = try container.decodeIfPresent(Bool.self, forKey: .hasOdds)
        playCount = try container.decodeIfPresent(Int.self, forKey: .playCount)
        socialPostCount = try container.decodeIfPresent(Int.self, forKey: .socialPostCount)
        hasRequiredData = try container.decodeIfPresent(Bool.self, forKey: .hasRequiredData)
        scrapeVersion = try container.decodeIfPresent(Int.self, forKey: .scrapeVersion)
        lastScrapedAt = try container.decodeIfPresent(String.self, forKey: .lastScrapedAt)
    }
    
    // Convenience init for mock data generation
    init(
        id: Int,
        leagueCode: String,
        gameDate: String,
        status: GameStatus?,
        homeTeam: String,
        awayTeam: String,
        homeScore: Int?,
        awayScore: Int?,
        hasBoxscore: Bool?,
        hasPlayerStats: Bool?,
        hasOdds: Bool?,
        hasSocial: Bool?,
        hasPbp: Bool?,
        playCount: Int?,
        socialPostCount: Int?,
        hasRequiredData: Bool?,
        scrapeVersion: Int?,
        lastScrapedAt: String?
    ) {
        self.id = id
        self.league = leagueCode
        self.leagueCode = leagueCode
        self.startTime = gameDate
        self.gameDate = gameDate
        self.statusRaw = status?.rawValue
        self.homeTeamInfo = TeamInfo(id: 0, name: homeTeam, abbreviation: String(homeTeam.prefix(3)).uppercased())
        self.awayTeamInfo = TeamInfo(id: 0, name: awayTeam, abbreviation: String(awayTeam.prefix(3)).uppercased())
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.hasBoxscore = hasBoxscore
        self.hasPlayerStats = hasPlayerStats
        self.hasOdds = hasOdds
        self.hasSocial = hasSocial
        self.hasPbp = hasPbp
        self.playCount = playCount
        self.socialPostCount = socialPostCount
        self.hasRequiredData = hasRequiredData
        self.scrapeVersion = scrapeVersion
        self.lastScrapedAt = lastScrapedAt
        self.lastUpdatedAt = lastScrapedAt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GameSummary, rhs: GameSummary) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Computed Properties
extension GameSummary {
    private enum Formatting {
        static let startsAtPrefix = "Starts at "
        static let inProgressText = "Live"
        static let completedText = "Final — recap available"
        static let postponedText = "Postponed"
        static let canceledText = "Canceled"
        static let statusUnavailableText = "Status unavailable"
    }
    
    /// Normalized status from API string to GameStatus enum
    var status: GameStatus? {
        guard let raw = statusRaw?.lowercased() else { return nil }
        switch raw {
        case "final", "completed":
            return .completed
        case "live", "in_progress", "inprogress":
            return .inProgress
        case "scheduled", "upcoming":
            return .scheduled
        case "postponed":
            return .postponed
        case "canceled", "cancelled":
            return .canceled
        default:
            return nil
        }
    }
    
    /// Convenience accessors for team names (for backward compatibility)
    var homeTeamName: String { homeTeamInfo.name }
    var awayTeamName: String { awayTeamInfo.name }
    var homeTeamAbbreviation: String { homeTeamInfo.abbreviation }
    var awayTeamAbbreviation: String { awayTeamInfo.abbreviation }
    
    /// League code for backward compatibility
    var leagueCodeValue: String { league }

    /// Formatted score string (e.g., "112 - 108")
    var scoreDisplay: String {
        guard let home = homeScore, let away = awayScore else {
            return "— vs —"
        }
        return "\(home) - \(away)"
    }
    
    /// Parsed game date
    var parsedGameDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: startTime) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: startTime)
    }
    
    /// Formatted date for display
    var formattedDate: String {
        guard let date = parsedGameDate else { return startTime }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Short formatted date (e.g., "Jan 1 • 7:30 PM")
    var shortFormattedDate: String {
        guard let date = parsedGameDate else { return startTime }
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d")
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return "\(dateFormatter.string(from: date)) • \(timeFormatter.string(from: date))"
    }

    var statusLine: String {
        // The backend status is the source of truth; do not infer from scores or timestamps.
        guard let status else {
            GameStatusLogger.logMissingStatus(gameId: id, league: league)
            return Formatting.statusUnavailableText
        }

        switch status {
        case .scheduled:
            guard let date = parsedGameDate else { return Formatting.startsAtPrefix + formattedDate }
            return Formatting.startsAtPrefix + formattedTime(date: date)
        case .inProgress:
            return Formatting.inProgressText
        case .completed, .final:
            return Formatting.completedText
        case .postponed:
            return Formatting.postponedText
        case .canceled:
            return Formatting.canceledText
        }
    }
    
    private func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

}

