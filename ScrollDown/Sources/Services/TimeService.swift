import Foundation
import OSLog

/// Centralized time service for the app
/// Beta Admin Feature: Supports time override for testing historical data
///
/// WHY THIS EXISTS:
/// - Enables deterministic testing of historical data
/// - Allows "time travel" to validate completed games
/// - Ensures no view/viewmodel calls Date() directly for logic
/// - Production: always uses real system time
/// - Beta: can freeze time to a specific moment
final class TimeService: ObservableObject {
    static let shared = TimeService()
    
    private let logger = Logger(subsystem: "com.scrolldown.app", category: "time")
    
    /// Beta-only time override
    /// When set, this value is treated as "now" throughout the app
    /// When nil, uses real system time
    @Published private var overrideDate: Date?
    
    private init() {
        loadOverrideFromEnvironment()
    }
    
    // MARK: - Public API
    
    /// Current time according to the app
    /// - In production: always returns Date()
    /// - In beta with override: returns frozen time
    var now: Date {
        if let override = overrideDate {
            return override
        }
        return Date()
    }
    
    /// Whether snapshot mode is active
    var isSnapshotModeActive: Bool {
        overrideDate != nil
    }
    
    /// Get the override date if set
    var snapshotDate: Date? {
        overrideDate
    }
    
    /// Set time override (beta only)
    /// - Parameter date: The date to treat as "now", or nil to use real time
    func setTimeOverride(_ date: Date?) {
        #if DEBUG
        overrideDate = date
        
        if let date = date {
            logger.info("⏰ Time override enabled: \(date.ISO8601Format())")
            logger.info("⏰ Real device time: \(Date().ISO8601Format())")
        } else {
            logger.info("⏰ Time override disabled, using real time")
        }
        #else
        // Production: ignore override attempts
        logger.warning("⚠️ Time override attempted in production build, ignoring")
        #endif
    }
    
    /// Clear time override
    func clearTimeOverride() {
        setTimeOverride(nil)
    }
    
    // MARK: - Environment Loading
    
    /// Load time override from environment variable
    /// Env var: IOS_BETA_ASSUME_NOW=2024-02-15T04:00:00Z
    private func loadOverrideFromEnvironment() {
        #if DEBUG
        guard let envValue = ProcessInfo.processInfo.environment["IOS_BETA_ASSUME_NOW"],
              !envValue.isEmpty else {
            logger.info("⏰ No time override in environment, using real time")
            return
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: envValue) {
            overrideDate = date
            logger.info("⏰ Time override loaded from environment: \(date.ISO8601Format())")
            logger.info("⏰ Real device time: \(Date().ISO8601Format())")
        } else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: envValue) {
                overrideDate = date
                logger.info("⏰ Time override loaded from environment: \(date.ISO8601Format())")
                logger.info("⏰ Real device time: \(Date().ISO8601Format())")
            } else {
                logger.error("⚠️ Invalid time override format in environment: \(envValue)")
                logger.error("⚠️ Expected ISO8601 format: 2024-02-15T04:00:00Z")
            }
        }
        #endif
    }
    
    // MARK: - Convenience Methods
    
    /// Format snapshot date for display
    var snapshotDateDisplay: String? {
        guard let date = overrideDate else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Date Extensions

extension Date {
    /// Check if this date is "today" according to TimeService
    var isToday: Bool {
        Calendar.current.isDate(self, inSameDayAs: TimeService.shared.now)
    }
    
    /// Check if this date is in the past according to TimeService
    var isInPast: Bool {
        self < TimeService.shared.now
    }
    
    /// Check if this date is in the future according to TimeService
    var isInFuture: Bool {
        self > TimeService.shared.now
    }
}
