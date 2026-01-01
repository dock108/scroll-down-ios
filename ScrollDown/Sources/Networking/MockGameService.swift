import Foundation

/// Mock implementation of GameService that loads data from bundled JSON files
/// Used for development and testing without network dependencies
final class MockGameService: GameService {
    
    // MARK: - Cache for loaded data
    private var gameCache: [Int: GameDetailResponse] = [:]
    private var gameListCache: GameListResponse?
    
    // MARK: - GameService Implementation
    
    func fetchGame(id: Int) async throws -> GameDetailResponse {
        // Simulate network delay for realistic feel
        try await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // Check cache first
        if let cached = gameCache[id] {
            return cached
        }
        
        // Try to load specific game file
        let filename = "game-\(String(format: "%03d", id == 12345 ? 1 : 2))"
        let result: Result<GameDetailResponse, Error> = MockLoader.loadResult(filename)
        
        switch result {
        case .success(let response):
            gameCache[id] = response
            return response
        case .failure:
            // Fallback to game-001
            let fallback: GameDetailResponse = MockLoader.load("game-001")
            gameCache[id] = fallback
            return fallback
        }
    }
    
    func fetchGames(league: LeagueCode?, limit: Int, offset: Int) async throws -> GameListResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        // Load game list from mock data
        if gameListCache == nil {
            gameListCache = MockLoader.load("game-list")
        }
        
        guard var response = gameListCache else {
            throw GameServiceError.notFound
        }
        
        // Apply league filter if specified
        if let league = league {
            let filteredGames = response.games.filter { $0.leagueCode == league.rawValue }
            response = GameListResponse(
                games: filteredGames,
                total: filteredGames.count,
                nextOffset: nil,
                withBoxscoreCount: response.withBoxscoreCount,
                withPlayerStatsCount: response.withPlayerStatsCount,
                withOddsCount: response.withOddsCount,
                withSocialCount: response.withSocialCount,
                withPbpCount: response.withPbpCount
            )
        }
        
        return response
    }
    
    func fetchPbp(gameId: Int) async throws -> PbpResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        return MockLoader.load("pbp-001")
    }
    
    func fetchSocialPosts(gameId: Int) async throws -> SocialPostListResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        return MockLoader.load("social-posts")
    }
}

