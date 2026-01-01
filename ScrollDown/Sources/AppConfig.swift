import Foundation

/// Data mode for switching between mock and API data sources
enum DataMode: String, CaseIterable {
    case mock
    case api
    
    var displayName: String {
        switch self {
        case .mock: return "Mock Data"
        case .api: return "Live API"
        }
    }
}

/// App-wide configuration singleton
final class AppConfig: ObservableObject {
    static let shared = AppConfig()
    
    /// Current data mode - defaults to mock for development
    @Published var dataMode: DataMode = .mock
    
    /// Returns the appropriate GameService based on current data mode
    var gameService: any GameService {
        switch dataMode {
        case .mock:
            return MockGameService()
        case .api:
            return RealGameService()
        }
    }
    
    private init() {}
}

