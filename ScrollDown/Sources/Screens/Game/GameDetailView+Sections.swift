import SwiftUI

extension GameDetailView {
    var displayOptionsSection: some View {
        SectionCardView(title: "Recap Style", subtitle: "Choose your flow") {
            Toggle("Compact Mode", isOn: $isCompactMode)
                .tint(GameTheme.accentColor)
        }
        .accessibilityHint("Switch to a chapter-based recap flow")
    }

    var overviewSection: some View {
        CollapsibleSectionCard(
            title: "Overview",
            subtitle: "Recap",
            isExpanded: $isOverviewExpanded
        ) {
            overviewContent
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Game overview")
    }

    var overviewContent: some View {
        VStack(alignment: .leading, spacing: Layout.textSpacing) {
            aiSummaryView

            VStack(alignment: .leading, spacing: Layout.listSpacing) {
                ForEach(viewModel.recapBullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: Layout.listSpacing) {
                        Circle()
                            .frame(width: Layout.bulletSize, height: Layout.bulletSize)
                            .foregroundColor(.secondary)
                            .padding(.top, Layout.bulletOffset)
                        Text(bullet)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    var preGameSection: some View {
        CollapsibleSectionCard(
            title: "Pre-Game",
            subtitle: "Before tipoff",
            isExpanded: $isPreGameExpanded
        ) {
            preGameContent
        }
        .accessibilityHint("Expands to show pre-game posts")
    }

    var preGameContent: some View {
        VStack(spacing: Layout.cardSpacing) {
            ForEach(viewModel.preGamePosts) { post in
                HighlightCardView(post: post)
            }

            if viewModel.preGamePosts.isEmpty {
                EmptySectionView(text: "Pre-game posts will appear here.")
            }
        }
    }

    func timelineSection(using proxy: ScrollViewProxy) -> some View {
        CollapsibleSectionCard(
            title: "Timeline",
            subtitle: "Play-by-play",
            isExpanded: $isTimelineExpanded
        ) {
            timelineContent(using: proxy)
        }
        .onChange(of: viewModel.timelineQuarters) { quarters in
            guard !hasInitializedQuarters else { return }
            // Q1 expanded, Q2+ collapsed per spec
            collapsedQuarters = Set(quarters.filter { $0.quarter > 1 }.map(\.quarter))
            hasInitializedQuarters = true
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: TimelineFramePreferenceKey.self,
                    value: proxy.frame(in: .named(Layout.scrollCoordinateSpace))
                )
            }
        )
        .accessibilityElement(children: .contain)
    }

    func timelineContent(using proxy: ScrollViewProxy) -> some View {
        VStack(spacing: Layout.cardSpacing) {
            if let liveMarker = viewModel.liveScoreMarker {
                TimelineScoreChipView(marker: liveMarker)
            }

            ForEach(viewModel.timelineQuarters) { quarter in
                quarterSection(quarter, using: proxy)
            }

            if viewModel.timelineQuarters.isEmpty {
                EmptySectionView(text: "No play-by-play data available.")
            }
        }
    }

    func quarterSection(
        _ quarter: GameDetailViewModel.QuarterTimeline,
        using proxy: ScrollViewProxy
    ) -> some View {
        CollapsibleQuarterCard(
            title: "\(quarterTitle(quarter.quarter)) (\(quarter.plays.count) plays)",
            isExpanded: Binding(
                get: { !collapsedQuarters.contains(quarter.quarter) },
                set: { isExpanded in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        if isExpanded {
                            collapsedQuarters.remove(quarter.quarter)
                        } else {
                            collapsedQuarters.insert(quarter.quarter)
                        }
                    }
                    if isExpanded {
                        scrollToQuarterHeader(quarter.quarter, using: proxy)
                    }
                }
            )
        ) {
            VStack(spacing: Layout.cardSpacing) {
                ForEach(quarter.plays) { play in
                    if let highlights = viewModel.highlightByPlayIndex[play.playIndex] {
                        ForEach(highlights) { highlight in
                            HighlightCardView(post: highlight)
                        }
                    }

                    TimelineRowView(play: play)
                        .id("play-\(play.playIndex)")
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: PlayRowFramePreferenceKey.self,
                                    value: [play.playIndex: proxy.frame(in: .named(Layout.scrollCoordinateSpace))]
                                )
                            }
                        )

                    if let marker = viewModel.scoreMarker(for: play) {
                        TimelineScoreChipView(marker: marker)
                    }
                }
            }
            .padding(.top, Layout.listSpacing)
        }
        .id(quarterAnchorId(quarter.quarter))
    }

    func playerStatsSection(_ stats: [PlayerStat]) -> some View {
        CollapsibleSectionCard(
            title: "Player Stats",
            subtitle: "Individual performance",
            isExpanded: $isPlayerStatsExpanded
        ) {
            playerStatsContent(stats)
        }
    }

    func playerStatsContent(_ stats: [PlayerStat]) -> some View {
        if stats.isEmpty {
            EmptySectionView(text: "Player stats are not yet available.")
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    playerStatsHeader
                    ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                        playerStatsRow(stat, isAlternate: index.isMultiple(of: 2))
                    }
                }
                .frame(minWidth: Layout.statsTableWidth)
            }
        }
    }

    var playerStatsHeader: some View {
        HStack(spacing: Layout.statsColumnSpacing) {
            Text("Player")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("PTS")
                .frame(width: Layout.statColumnWidth)
            Text("REB")
                .frame(width: Layout.statColumnWidth)
            Text("AST")
                .frame(width: Layout.statColumnWidth)
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(.secondary)
        .padding(.vertical, Layout.listSpacing)
        .padding(.horizontal, Layout.statsHorizontalPadding)
        .background(Color(.systemGray6))
    }

    func playerStatsRow(_ stat: PlayerStat, isAlternate: Bool) -> some View {
        HStack(spacing: Layout.statsColumnSpacing) {
            VStack(alignment: .leading, spacing: Layout.smallSpacing) {
                Text(stat.playerName)
                    .font(.subheadline.weight(.medium))
                Text(stat.team)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(stat.points.map(String.init) ?? Constants.statFallback)
                .frame(width: Layout.statColumnWidth)
            Text(stat.rebounds.map(String.init) ?? Constants.statFallback)
                .frame(width: Layout.statColumnWidth)
            Text(stat.assists.map(String.init) ?? Constants.statFallback)
                .frame(width: Layout.statColumnWidth)
        }
        .font(.subheadline)
        .padding(.vertical, Layout.listSpacing)
        .padding(.horizontal, Layout.statsHorizontalPadding)
        .background(isAlternate ? Color(.systemGray6) : Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(stat.playerName), \(stat.team)")
        .accessibilityValue("Points \(stat.points ?? 0), rebounds \(stat.rebounds ?? 0), assists \(stat.assists ?? 0)")
    }

    func teamStatsSection(_ stats: [TeamStat]) -> some View {
        CollapsibleSectionCard(
            title: "Team Stats",
            subtitle: "How the game unfolded",
            isExpanded: $isTeamStatsExpanded
        ) {
            teamStatsContent(stats)
        }
    }

    func teamStatsContent(_ stats: [TeamStat]) -> some View {
        if viewModel.teamComparisonStats.isEmpty {
            EmptySectionView(text: "Team stats will appear once available.")
        } else {
            VStack(spacing: Layout.listSpacing) {
                ForEach(viewModel.teamComparisonStats) { stat in
                    TeamComparisonRowView(
                        stat: stat,
                        homeTeam: stats.first(where: { $0.isHome })?.team ?? "Home",
                        awayTeam: stats.first(where: { !$0.isHome })?.team ?? "Away"
                    )
                }
            }
        }
    }

    var finalScoreSection: some View {
        CollapsibleSectionCard(
            title: "Final Score",
            subtitle: "Wrap-up",
            isExpanded: $isFinalScoreExpanded
        ) {
            finalScoreContent
        }
    }

    var finalScoreContent: some View {
        VStack(spacing: Layout.textSpacing) {
            Text(viewModel.game?.scoreDisplay ?? Constants.scoreFallback)
                .font(.system(size: Layout.finalScoreSize, weight: .bold))
            Text("Final")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.listSpacing)
    }

    var postGameSection: some View {
        CollapsibleSectionCard(
            title: "Post-Game",
            subtitle: "Reactions",
            isExpanded: $isPostGameExpanded
        ) {
            postGameContent
        }
        .accessibilityHint("Expands to show post-game posts")
    }

    var postGameContent: some View {
        VStack(spacing: Layout.cardSpacing) {
            ForEach(viewModel.postGamePosts) { post in
                HighlightCardView(post: post)
            }

            if viewModel.postGamePosts.isEmpty {
                EmptySectionView(text: "Post-game posts will appear here.")
            }
        }
    }

    var compactPostsContent: some View {
        VStack(alignment: .leading, spacing: Layout.cardSpacing) {
            if viewModel.preGamePosts.isEmpty && viewModel.postGamePosts.isEmpty {
                EmptySectionView(text: "Posts will appear here.")
            } else {
                compactPostsSection(
                    title: "Pre-Game",
                    posts: viewModel.preGamePosts,
                    emptyText: "Pre-game posts will appear here."
                )
                compactPostsSection(
                    title: "Post-Game",
                    posts: viewModel.postGamePosts,
                    emptyText: "Post-game posts will appear here."
                )
            }

            relatedPostsCompactSection
        }
    }

    // MARK: - Helper Views

    func sectionNavigationBar(onSelect: @escaping (GameSection) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Layout.navigationSpacing) {
                ForEach(GameSection.navigationSections, id: \.self) { section in
                    Button {
                        onSelect(section)
                    } label: {
                        Text(section.title)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, Layout.navigationHorizontalPadding)
                            .padding(.vertical, Layout.navigationVerticalPadding)
                            .foregroundColor(selectedSection == section ? .white : .primary)
                            .background(selectedSection == section ? GameTheme.accentColor : Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel("Jump to \(section.title)")
                }
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.listSpacing)
        }
        .background(Color(.systemBackground))
        .overlay(
            Divider(),
            alignment: .bottom
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Section navigation")
    }

    func compactChapterSection(
        number: Int,
        title: String,
        subtitle: String?,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: Layout.chapterSpacing) {
            Text("Chapter \(number)")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, Layout.chapterHorizontalPadding)
            CollapsibleSectionCard(
                title: title,
                subtitle: subtitle,
                isExpanded: isExpanded
            ) {
                content()
            }
        }
    }

    func compactPostsSection(
        title: String,
        posts: [SocialPostEntry],
        emptyText: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Layout.listSpacing) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
            if posts.isEmpty {
                EmptySectionView(text: emptyText)
            } else {
                ForEach(posts) { post in
                    HighlightCardView(post: post)
                }
            }
        }
    }

    var relatedPostsSection: some View {
        CollapsibleSectionCard(
            title: "Related Posts",
            subtitle: "More coverage",
            isExpanded: $isRelatedPostsExpanded
        ) {
            relatedPostsContent
        }
        .accessibilityHint("Expands to show related posts")
    }

    var relatedPostsCompactSection: some View {
        VStack(alignment: .leading, spacing: Layout.listSpacing) {
            Text("Related")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
            relatedPostsContent
        }
    }

    var relatedPostsContent: some View {
        VStack(alignment: .leading, spacing: Layout.cardSpacing) {
            switch viewModel.relatedPostsState {
            case .idle, .loading:
                HStack(spacing: Layout.listSpacing) {
                    ProgressView()
                    Text("Loading related posts...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            case .failed(let message):
                VStack(alignment: .leading, spacing: Layout.listSpacing) {
                    Text("Related posts unavailable.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        Task { await viewModel.loadRelatedPosts(gameId: gameId, service: appConfig.gameService) }
                    }
                    .buttonStyle(.bordered)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            case .loaded:
                if viewModel.relatedPosts.isEmpty {
                    EmptySectionView(text: "Related posts will appear here.")
                } else {
                    LazyVStack(spacing: Layout.cardSpacing) {
                        ForEach(viewModel.relatedPosts) { post in
                            RelatedPostCardView(
                                post: post,
                                isRevealed: viewModel.isRelatedPostRevealed(post),
                                onReveal: {
                                    withAnimation(.easeInOut) {
                                        viewModel.revealRelatedPost(id: post.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadRelatedPosts(gameId: gameId, service: appConfig.gameService)
        }
    }
}
