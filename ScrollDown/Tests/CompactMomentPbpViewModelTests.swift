import XCTest
@testable import ScrollDown

final class CompactMomentPbpViewModelTests: XCTestCase {
    @MainActor
    func testOrderedEventsFiltersFuturePlaysAndSortsChronologically() {
        let viewModel = CompactMomentPbpViewModel()
        let moment = CompactMoment(
            id: .int(10),
            period: 1,
            gameClock: "11:00",
            title: nil,
            description: nil,
            teamAbbreviation: nil,
            playerName: nil
        )

        let events = [
            PbpEvent(
                id: .int(2),
                gameId: .int(1),
                period: 1,
                gameClock: "10:30",
                elapsedSeconds: 90,
                eventType: "made_shot",
                description: "Later bucket",
                team: nil,
                teamId: nil,
                playerName: nil,
                playerId: nil,
                homeScore: nil,
                awayScore: nil
            ),
            PbpEvent(
                id: .int(1),
                gameId: .int(1),
                period: 1,
                gameClock: "12:00",
                elapsedSeconds: 0,
                eventType: "jump_ball",
                description: "Start",
                team: nil,
                teamId: nil,
                playerName: nil,
                playerId: nil,
                homeScore: nil,
                awayScore: nil
            ),
            PbpEvent(
                id: .int(3),
                gameId: .int(1),
                period: 1,
                gameClock: "11:30",
                elapsedSeconds: 30,
                eventType: "foul",
                description: "Mid-sequence",
                team: nil,
                teamId: nil,
                playerName: nil,
                playerId: nil,
                homeScore: nil,
                awayScore: nil
            )
        ]

        let ordered = viewModel.orderedEvents(for: moment, events: events)

        XCTAssertEqual(ordered.compactMap { $0.id.intValue }, [1, 3])
    }
}
