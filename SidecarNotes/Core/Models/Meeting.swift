import Foundation

// MARK: - Meeting Models

struct Meeting: Identifiable, Codable {
    let id: UUID
    var title: String?
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var audioFilePath: URL?
    var transcript: [TranscriptSegment]
    var summary: MeetingSummary?
    var participants: [Speaker]
    var detectedPlatform: MeetingPlatform?
    var audioQualityMetrics: AudioQualityMetrics?
    
    init(title: String? = nil, startTime: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.startTime = startTime
        self.endTime = nil
        self.audioFilePath = nil
        self.transcript = []
        self.summary = nil
        self.participants = []
        self.detectedPlatform = nil
        self.audioQualityMetrics = nil
    }
    
    var isComplete: Bool {
        return endTime != nil
    }
    
    var displayTitle: String {
        return title ?? "Meeting \(startTime.formatted(date: .abbreviated, time: .shortened))"
    }
    
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Transcript Models

struct TranscriptSegment: Identifiable, Codable {
    let id: UUID
    let text: String
    let startTime: TimeInterval
    let duration: TimeInterval
    let speakerID: UUID?
    let confidence: Float
    let words: [TranscribedWord]
    
    init(text: String, startTime: TimeInterval, duration: TimeInterval, speakerID: UUID? = nil, confidence: Float = 1.0, words: [TranscribedWord] = []) {
        self.id = UUID()
        self.text = text
        self.startTime = startTime
        self.duration = duration
        self.speakerID = speakerID
        self.confidence = confidence
        self.words = words
    }
    
    var endTime: TimeInterval {
        return startTime + duration
    }
    
    var formattedTime: String {
        let totalSeconds = Int(startTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.9...1.0: return .high
        case 0.7..<0.9: return .medium
        case 0.0..<0.7: return .low
        default: return .unknown
        }
    }
}

struct TranscribedWord: Identifiable, Codable {
    let id: UUID
    let text: String
    let startTime: TimeInterval
    let duration: TimeInterval
    let confidence: Float
    
    init(text: String, startTime: TimeInterval, duration: TimeInterval, confidence: Float) {
        self.id = UUID()
        self.text = text
        self.startTime = startTime
        self.duration = duration
        self.confidence = confidence
    }
}

enum ConfidenceLevel: String, CaseIterable, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    case unknown = "unknown"
    
    var description: String {
        switch self {
        case .high: return "High Confidence"
        case .medium: return "Medium Confidence"
        case .low: return "Low Confidence"
        case .unknown: return "Unknown"
        }
    }
    
    var color: String {
        switch self {
        case .high: return "green"
        case .medium: return "orange"
        case .low: return "red"
        case .unknown: return "gray"
        }
    }
}

// MARK: - Meeting Summary Models

struct MeetingSummary: Codable {
    let id: UUID
    let overview: String
    let keyDecisions: [Decision]
    let actionItems: [ActionItem]
    let keyTopics: [Topic]
    let participants: [Participant]
    let nextSteps: [NextStep]
    let risks: [Risk]
    let opportunities: [Opportunity]
    let generatedAt: Date
    let confidence: Float
    
    init(overview: String, keyDecisions: [Decision] = [], actionItems: [ActionItem] = [], keyTopics: [Topic] = [], participants: [Participant] = [], nextSteps: [NextStep] = [], risks: [Risk] = [], opportunities: [Opportunity] = [], confidence: Float = 0.8) {
        self.id = UUID()
        self.overview = overview
        self.keyDecisions = keyDecisions
        self.actionItems = actionItems
        self.keyTopics = keyTopics
        self.participants = participants
        self.nextSteps = nextSteps
        self.risks = risks
        self.opportunities = opportunities
        self.generatedAt = Date()
        self.confidence = confidence
    }
}

struct Decision: Identifiable, Codable {
    let id: UUID
    let description: String
    let decisionMaker: UUID?
    let timestamp: TimeInterval
    let confidence: Float
    let context: String?
    let impact: DecisionImpact
    
    init(description: String, decisionMaker: UUID? = nil, timestamp: TimeInterval, confidence: Float = 0.8, context: String? = nil, impact: DecisionImpact = .medium) {
        self.id = UUID()
        self.description = description
        self.decisionMaker = decisionMaker
        self.timestamp = timestamp
        self.confidence = confidence
        self.context = context
        self.impact = impact
    }
}

struct ActionItem: Identifiable, Codable {
    let id: UUID
    var description: String
    var assignee: UUID?
    var dueDate: Date?
    var priority: Priority
    var status: ActionItemStatus
    let context: String?
    let timestamp: TimeInterval
    
    init(description: String, assignee: UUID? = nil, dueDate: Date? = nil, priority: Priority = .medium, status: ActionItemStatus = .open, context: String? = nil, timestamp: TimeInterval) {
        self.id = UUID()
        self.description = description
        self.assignee = assignee
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
        self.context = context
        self.timestamp = timestamp
    }
}

struct Topic: Identifiable, Codable {
    let id: UUID
    let topic: String
    let importance: Float
    let timeSpent: TimeInterval
    let relatedSegments: [UUID]
    
    init(topic: String, importance: Float = 0.5, timeSpent: TimeInterval = 0, relatedSegments: [UUID] = []) {
        self.id = UUID()
        self.topic = topic
        self.importance = importance
        self.timeSpent = timeSpent
        self.relatedSegments = relatedSegments
    }
}

struct Participant: Identifiable, Codable {
    let id: UUID
    let name: String
    let speakingTime: TimeInterval
    let contributionLevel: ContributionLevel
    let keyContributions: [String]
    
    init(name: String, speakingTime: TimeInterval = 0, contributionLevel: ContributionLevel = .medium, keyContributions: [String] = []) {
        self.id = UUID()
        self.name = name
        self.speakingTime = speakingTime
        self.contributionLevel = contributionLevel
        self.keyContributions = keyContributions
    }
}

struct NextStep: Identifiable, Codable {
    let id: UUID
    let description: String
    let owner: UUID?
    let timeframe: String?
    
    init(description: String, owner: UUID? = nil, timeframe: String? = nil) {
        self.id = UUID()
        self.description = description
        self.owner = owner
        self.timeframe = timeframe
    }
}

struct Risk: Identifiable, Codable {
    let id: UUID
    let description: String
    let severity: RiskLevel
    let mitigation: String?
    
    init(description: String, severity: RiskLevel = .medium, mitigation: String? = nil) {
        self.id = UUID()
        self.description = description
        self.severity = severity
        self.mitigation = mitigation
    }
}

struct Opportunity: Identifiable, Codable {
    let id: UUID
    let description: String
    let potential: OpportunityLevel
    let actionRequired: String?
    
    init(description: String, potential: OpportunityLevel = .medium, actionRequired: String? = nil) {
        self.id = UUID()
        self.description = description
        self.potential = potential
        self.actionRequired = actionRequired
    }
}

// MARK: - Supporting Enums

enum DecisionImpact: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var description: String {
        switch self {
        case .low: return "Low Impact"
        case .medium: return "Medium Impact"
        case .high: return "High Impact"
        case .critical: return "Critical Impact"
        }
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var description: String {
        switch self {
        case .low: return "Low Priority"
        case .medium: return "Medium Priority"
        case .high: return "High Priority"
        case .urgent: return "Urgent"
        }
    }
    
    var emoji: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🔴"
        case .urgent: return "🚨"
        }
    }
}

enum ActionItemStatus: String, CaseIterable, Codable {
    case open = "open"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var description: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

enum ContributionLevel: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var description: String {
        switch self {
        case .low: return "Limited Contribution"
        case .medium: return "Active Participant"
        case .high: return "Key Contributor"
        }
    }
}

enum RiskLevel: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var description: String {
        switch self {
        case .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        case .critical: return "Critical Risk"
        }
    }
}

enum OpportunityLevel: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var description: String {
        switch self {
        case .low: return "Small Opportunity"
        case .medium: return "Good Opportunity"
        case .high: return "Major Opportunity"
        }
    }
}

enum MeetingPlatform: String, CaseIterable, Codable {
    case zoom = "zoom"
    case microsoftTeams = "teams"
    case googleMeet = "meet"
    case webex = "webex"
    case slack = "slack"
    case discord = "discord"
    case genericBrowser = "browser"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .zoom: return "Zoom"
        case .microsoftTeams: return "Microsoft Teams"
        case .googleMeet: return "Google Meet"
        case .webex: return "WebEx"
        case .slack: return "Slack"
        case .discord: return "Discord"
        case .genericBrowser: return "Web Browser"
        case .unknown: return "Unknown Platform"
        }
    }
}

// MARK: - Audio Quality Models

struct AudioQualityMetrics: Codable {
    let overallScore: Float
    let signalToNoiseRatio: Float
    let dynamicRange: Float
    let clarityScore: Float
    let synchronizationDrift: TimeInterval
    let dropoutCount: Int
    let averageLevel: Float
    
    init(overallScore: Float = 0.8, signalToNoiseRatio: Float = 30.0, dynamicRange: Float = 40.0, clarityScore: Float = 0.85, synchronizationDrift: TimeInterval = 0.001, dropoutCount: Int = 0, averageLevel: Float = -12.0) {
        self.overallScore = overallScore
        self.signalToNoiseRatio = signalToNoiseRatio
        self.dynamicRange = dynamicRange
        self.clarityScore = clarityScore
        self.synchronizationDrift = synchronizationDrift
        self.dropoutCount = dropoutCount
        self.averageLevel = averageLevel
    }
    
    var qualityLevel: AudioQualityLevel {
        switch overallScore {
        case 0.9...1.0: return .excellent
        case 0.7..<0.9: return .good
        case 0.5..<0.7: return .acceptable
        case 0.0..<0.5: return .poor
        default: return .unknown
        }
    }
}

enum AudioQualityLevel: String, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case acceptable = "acceptable"
    case poor = "poor"
    case unknown = "unknown"
    
    var description: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .acceptable: return "Acceptable"
        case .poor: return "Poor"
        case .unknown: return "Unknown"
        }
    }
    
    var emoji: String {
        switch self {
        case .excellent: return "🟢"
        case .good: return "🔵"
        case .acceptable: return "🟡"
        case .poor: return "🔴"
        case .unknown: return "⚪"
        }
    }
}