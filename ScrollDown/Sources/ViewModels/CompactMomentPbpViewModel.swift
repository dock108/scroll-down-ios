import Foundation

@MainActor
final class CompactMomentPbpViewModel: ObservableObject {
    @Published private(set) var events: [PbpEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var loadedMomentId: String?

    func load(moment: CompactMoment, service: GameService) async {
        let momentId = moment.id.stringValue
        guard loadedMomentId != momentId else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.fetchCompactMomentPbp(momentId: moment.id)
            events = orderedEvents(for: moment, events: response.events)
            loadedMomentId = momentId
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func orderedEvents(for moment: CompactMoment, events: [PbpEvent]) -> [PbpEvent] {
        let filtered = filteredEvents(for: moment, events: events)
        return sortChronological(filtered)
    }

    private func filteredEvents(for moment: CompactMoment, events: [PbpEvent]) -> [PbpEvent] {
        guard let momentElapsed = elapsedSeconds(for: moment) else {
            return events
        }

        return events.filter { event in
            guard let eventElapsed = elapsedSeconds(for: event) else {
                return true
            }
            return eventElapsed <= momentElapsed
        }
    }

    private func sortChronological(_ events: [PbpEvent]) -> [PbpEvent] {
        events.enumerated().sorted { lhs, rhs in
            let leftKey = elapsedSeconds(for: lhs.element)
            let rightKey = elapsedSeconds(for: rhs.element)

            switch (leftKey, rightKey) {
            case let (left?, right?):
                if left == right {
                    return lhs.offset < rhs.offset
                }
                return left < right
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return lhs.offset < rhs.offset
            }
        }
        .map(\.element)
    }

    private func elapsedSeconds(for event: PbpEvent) -> Double? {
        if let elapsedSeconds = event.elapsedSeconds {
            return elapsedSeconds
        }

        return elapsedSeconds(period: event.period, gameClock: event.gameClock)
    }

    private func elapsedSeconds(for moment: CompactMoment) -> Double? {
        elapsedSeconds(period: moment.period, gameClock: moment.gameClock)
    }

    private func elapsedSeconds(period: Int?, gameClock: String?) -> Double? {
        guard let period, period > 0,
              let gameClock,
              let remainingSeconds = clockSeconds(from: gameClock) else {
            return nil
        }

        let periodLength = period <= Constants.regulationPeriods
            ? Constants.regulationPeriodSeconds
            : Constants.overtimePeriodSeconds

        let baseSeconds: Double
        if period <= Constants.regulationPeriods {
            baseSeconds = Double(period - 1) * Constants.regulationPeriodSeconds
        } else {
            let overtimeIndex = period - Constants.regulationPeriods - 1
            baseSeconds = (Double(Constants.regulationPeriods) * Constants.regulationPeriodSeconds)
                + (Double(overtimeIndex) * Constants.overtimePeriodSeconds)
        }

        let elapsedInPeriod = max(0, periodLength - remainingSeconds)
        return baseSeconds + elapsedInPeriod
    }

    private func clockSeconds(from clock: String) -> Double? {
        let parts = clock.split(separator: ":")
        guard parts.count == 2,
              let minutes = Double(parts[0]),
              let seconds = Double(parts[1]) else {
            return nil
        }
        return (minutes * Constants.secondsPerMinute) + seconds
    }
}

private enum Constants {
    static let regulationPeriods = 4
    static let regulationPeriodSeconds: Double = 12 * 60
    static let overtimePeriodSeconds: Double = 5 * 60
    static let secondsPerMinute: Double = 60
}
