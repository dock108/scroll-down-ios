import Foundation

enum APIConfiguration {
    static func baseURL(for environment: AppEnvironment) -> URL {
        let urlString: String
        switch environment {
        case .mock:
            urlString = "https://mock.scrolldown.sports"
        case .live:
            // Point to local infrastructure for development
            // Backend running on port 8000 per user infra screenshot
            urlString = "http://localhost:8000"
        }

        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid API base URL.")
        }
        return url
    }
}
