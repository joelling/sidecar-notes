import Foundation

// MARK: - Speaker Models

struct Speaker: Identifiable, Codable {
    let id: UUID
    var name: String?
    let voiceCharacteristics: VoiceCharacteristics
    var confidence: Float
    let createdDate: Date
    var lastUsedDate: Date
    var meetingCount: Int
    var totalSpeakingTime: TimeInterval
    var isLearned: Bool
    
    init(name: String? = nil, voiceCharacteristics: VoiceCharacteristics, confidence: Float = 0.5) {
        self.id = UUID()
        self.name = name
        self.voiceCharacteristics = voiceCharacteristics
        self.confidence = confidence
        self.createdDate = Date()
        self.lastUsedDate = Date()
        self.meetingCount = 0
        self.totalSpeakingTime = 0
        self.isLearned = false
    }
    
    var displayName: String {
        return name ?? "Unknown Speaker \(id.uuidString.prefix(8))"
    }
    
    var isIdentified: Bool {
        return name != nil
    }
    
    var averageSpeakingTimePerMeeting: TimeInterval {
        return meetingCount > 0 ? totalSpeakingTime / TimeInterval(meetingCount) : 0
    }
    
    mutating func updateUsage(speakingTime: TimeInterval) {
        lastUsedDate = Date()
        meetingCount += 1
        totalSpeakingTime += speakingTime
        
        // Improve confidence with more usage data
        let usageFactor = min(Float(meetingCount) / 10.0, 0.3) // Max 30% boost
        confidence = min(confidence + usageFactor, 1.0)
    }
    
    mutating func learnFromSamples(_ samples: [VoiceEmbedding]) {
        // Update voice characteristics based on new samples
        // This would integrate with the actual ML model
        isLearned = true
        confidence = max(confidence, 0.8) // Learned speakers get higher confidence
    }
}

// MARK: - Voice Characteristics

struct VoiceCharacteristics: Codable {
    let embedding: VoiceEmbedding
    let fundamentalFrequency: Float // Average pitch
    let spectralCentroid: Float // Brightness/timbre
    let formantFrequencies: [Float] // Vowel characteristics
    let speechRate: Float // Words per minute
    let energyDistribution: [Float] // Frequency energy bands
    
    init(embedding: VoiceEmbedding, fundamentalFrequency: Float = 150.0, spectralCentroid: Float = 2000.0, formantFrequencies: [Float] = [800, 1200, 2400], speechRate: Float = 150.0, energyDistribution: [Float] = [0.2, 0.3, 0.3, 0.2]) {
        self.embedding = embedding
        self.fundamentalFrequency = fundamentalFrequency
        self.spectralCentroid = spectralCentroid
        self.formantFrequencies = formantFrequencies
        self.speechRate = speechRate
        self.energyDistribution = energyDistribution
    }
    
    func similarity(to other: VoiceCharacteristics) -> Float {
        // Calculate overall similarity between voice characteristics
        let embeddingSimilarity = embedding.cosineSimilarity(to: other.embedding)
        let pitchSimilarity = 1.0 - abs(fundamentalFrequency - other.fundamentalFrequency) / max(fundamentalFrequency, other.fundamentalFrequency)
        let timbreSimilarity = 1.0 - abs(spectralCentroid - other.spectralCentroid) / max(spectralCentroid, other.spectralCentroid)
        let rateSimilarity = 1.0 - abs(speechRate - other.speechRate) / max(speechRate, other.speechRate)
        
        // Weighted average of different similarity metrics
        return (embeddingSimilarity * 0.5 + pitchSimilarity * 0.2 + timbreSimilarity * 0.2 + rateSimilarity * 0.1)
    }
    
    var estimatedGender: VoiceGender {
        // Simple heuristic based on fundamental frequency
        switch fundamentalFrequency {
        case 80...180: return .male
        case 165...265: return .female
        default: return .unknown
        }
    }
    
    var voiceType: VoiceType {
        // Classify voice type based on characteristics
        switch (fundamentalFrequency, spectralCentroid) {
        case (80...120, ...1800): return .bassBass
        case (110...150, 1500...2200): return .baritone
        case (140...180, 1800...2500): return .tenor
        case (200...250, 2000...3000): return .alto
        case (230...280, 2500...3500): return .soprano
        default: return .unknown
        }
    }
}

// MARK: - Voice Embedding

struct VoiceEmbedding: Codable {
    let features: [Float]
    let modelVersion: String
    let extractedAt: Date
    
    init(features: [Float], modelVersion: String = "1.0") {
        self.features = features
        self.modelVersion = modelVersion
        self.extractedAt = Date()
    }
    
    func cosineSimilarity(to other: VoiceEmbedding) -> Float {
        guard features.count == other.features.count else { return 0.0 }
        
        let dotProduct = zip(features, other.features).reduce(0) { result, pair in
            result + pair.0 * pair.1
        }
        
        let magnitude1 = sqrt(features.reduce(0) { $0 + $1 * $1 })
        let magnitude2 = sqrt(other.features.reduce(0) { $0 + $1 * $1 })
        
        guard magnitude1 > 0 && magnitude2 > 0 else { return 0.0 }
        
        return dotProduct / (magnitude1 * magnitude2)
    }
    
    func euclideanDistance(to other: VoiceEmbedding) -> Float {
        guard features.count == other.features.count else { return Float.infinity }
        
        let squaredDifferences = zip(features, other.features).map { pair in
            pow(pair.0 - pair.1, 2)
        }
        
        return sqrt(squaredDifferences.reduce(0, +))
    }
    
    var isValid: Bool {
        return !features.isEmpty && features.allSatisfy { $0.isFinite }
    }
}

// MARK: - Speaker Identification

struct SpeakerIdentification {
    let speakerID: UUID?
    let confidence: Float
    let isNewSpeaker: Bool
    let similarSpeakers: [SpeakerMatch]
    let audioSegment: AudioSegmentInfo
    
    init(speakerID: UUID? = nil, confidence: Float, isNewSpeaker: Bool = false, similarSpeakers: [SpeakerMatch] = [], audioSegment: AudioSegmentInfo) {
        self.speakerID = speakerID
        self.confidence = confidence
        self.isNewSpeaker = isNewSpeaker
        self.similarSpeakers = similarSpeakers
        self.audioSegment = audioSegment
    }
    
    var isReliable: Bool {
        return confidence >= 0.7
    }
}

struct SpeakerMatch {
    let speakerID: UUID
    let similarity: Float
    let confidence: Float
    
    init(speakerID: UUID, similarity: Float, confidence: Float) {
        self.speakerID = speakerID
        self.similarity = similarity
        self.confidence = confidence
    }
}

struct AudioSegmentInfo {
    let startTime: TimeInterval
    let duration: TimeInterval
    let audioQuality: Float
    let speechActivity: Float
    let backgroundNoise: Float
    
    init(startTime: TimeInterval, duration: TimeInterval, audioQuality: Float = 0.8, speechActivity: Float = 0.9, backgroundNoise: Float = 0.1) {
        self.startTime = startTime
        self.duration = duration
        self.audioQuality = audioQuality
        self.speechActivity = speechActivity
        self.backgroundNoise = backgroundNoise
    }
    
    var isSuitableForLearning: Bool {
        return duration >= 3.0 && // At least 3 seconds
               audioQuality >= 0.6 && // Decent audio quality
               speechActivity >= 0.8 && // High speech activity
               backgroundNoise <= 0.3 // Low background noise
    }
}

// MARK: - Speaker Clustering

struct SpeakerCluster {
    let id: UUID
    var speakerID: UUID?
    var embeddings: [VoiceEmbedding]
    var segments: [UUID] // TranscriptSegment IDs
    var centroid: VoiceEmbedding
    var cohesion: Float // How similar embeddings are within cluster
    
    init(embeddings: [VoiceEmbedding], segments: [UUID] = []) {
        self.id = UUID()
        self.speakerID = nil
        self.embeddings = embeddings
        self.segments = segments
        
        // Calculate centroid
        if let first = embeddings.first {
            var centroidFeatures = Array(repeating: Float(0), count: first.features.count)
            
            for embedding in embeddings {
                for (index, feature) in embedding.features.enumerated() {
                    centroidFeatures[index] += feature
                }
            }
            
            let count = Float(embeddings.count)
            centroidFeatures = centroidFeatures.map { $0 / count }
            
            self.centroid = VoiceEmbedding(features: centroidFeatures)
        } else {
            self.centroid = VoiceEmbedding(features: [])
        }
        
        // Calculate cohesion
        self.cohesion = calculateCohesion()
    }
    
    private func calculateCohesion() -> Float {
        guard embeddings.count > 1 else { return 1.0 }
        
        var totalSimilarity: Float = 0
        var pairCount = 0
        
        for i in 0..<embeddings.count {
            for j in (i+1)..<embeddings.count {
                totalSimilarity += embeddings[i].cosineSimilarity(to: embeddings[j])
                pairCount += 1
            }
        }
        
        return pairCount > 0 ? totalSimilarity / Float(pairCount) : 0
    }
    
    func distanceToCentroid(_ embedding: VoiceEmbedding) -> Float {
        return 1.0 - embedding.cosineSimilarity(to: centroid)
    }
    
    mutating func addEmbedding(_ embedding: VoiceEmbedding, segmentID: UUID) {
        embeddings.append(embedding)
        segments.append(segmentID)
        
        // Recalculate centroid
        updateCentroid()
        cohesion = calculateCohesion()
    }
    
    private mutating func updateCentroid() {
        guard !embeddings.isEmpty, let first = embeddings.first else { return }
        
        var centroidFeatures = Array(repeating: Float(0), count: first.features.count)
        
        for embedding in embeddings {
            for (index, feature) in embedding.features.enumerated() {
                centroidFeatures[index] += feature
            }
        }
        
        let count = Float(embeddings.count)
        centroidFeatures = centroidFeatures.map { $0 / count }
        
        centroid = VoiceEmbedding(features: centroidFeatures)
    }
}

// MARK: - Supporting Enums

enum VoiceGender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case unknown = "unknown"
    
    var description: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .unknown: return "Unknown"
        }
    }
}

enum VoiceType: String, CaseIterable, Codable {
    case bassBass = "bass"
    case baritone = "baritone"
    case tenor = "tenor"
    case alto = "alto"
    case soprano = "soprano"
    case unknown = "unknown"
    
    var description: String {
        switch self {
        case .bassBass: return "Bass"
        case .baritone: return "Baritone"
        case .tenor: return "Tenor"
        case .alto: return "Alto"
        case .soprano: return "Soprano"
        case .unknown: return "Unknown"
        }
    }
    
    var typicalRange: String {
        switch self {
        case .bassBass: return "80-120 Hz"
        case .baritone: return "110-150 Hz"
        case .tenor: return "140-180 Hz"
        case .alto: return "200-250 Hz"
        case .soprano: return "230-280 Hz"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Speaker Database

class SpeakerDatabase {
    static let shared = SpeakerDatabase()
    
    private var speakers: [UUID: Speaker] = [:]
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let speakersURL: URL
    
    private init() {
        speakersURL = documentsURL.appendingPathComponent("speakers.json")
        loadSpeakers()
    }
    
    // MARK: - Speaker Management
    
    func addSpeaker(_ speaker: Speaker) {
        speakers[speaker.id] = speaker
        saveSpeakers()
    }
    
    func getSpeaker(id: UUID) -> Speaker? {
        return speakers[id]
    }
    
    func getAllSpeakers() -> [Speaker] {
        return Array(speakers.values).sorted { $0.lastUsedDate > $1.lastUsedDate }
    }
    
    func updateSpeaker(_ speaker: Speaker) {
        speakers[speaker.id] = speaker
        saveSpeakers()
    }
    
    func deleteSpeaker(id: UUID) {
        speakers.removeValue(forKey: id)
        saveSpeakers()
    }
    
    func findSimilarSpeakers(to voiceCharacteristics: VoiceCharacteristics, threshold: Float = 0.7) -> [SpeakerMatch] {
        var matches: [SpeakerMatch] = []
        
        for speaker in speakers.values {
            let similarity = voiceCharacteristics.similarity(to: speaker.voiceCharacteristics)
            
            if similarity >= threshold {
                let match = SpeakerMatch(
                    speakerID: speaker.id,
                    similarity: similarity,
                    confidence: speaker.confidence
                )
                matches.append(match)
            }
        }
        
        return matches.sorted { $0.similarity > $1.similarity }
    }
    
    // MARK: - Persistence
    
    private func saveSpeakers() {
        do {
            let data = try JSONEncoder().encode(Array(speakers.values))
            try data.write(to: speakersURL)
        } catch {
            print("Failed to save speakers: \(error)")
        }
    }
    
    private func loadSpeakers() {
        do {
            let data = try Data(contentsOf: speakersURL)
            let speakerArray = try JSONDecoder().decode([Speaker].self, from: data)
            
            speakers = Dictionary(uniqueKeysWithValues: speakerArray.map { ($0.id, $0) })
        } catch {
            print("Failed to load speakers: \(error)")
            // Initialize with empty database
            speakers = [:]
        }
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> SpeakerDatabaseStats {
        let totalSpeakers = speakers.count
        let learnedSpeakers = speakers.values.filter { $0.isLearned }.count
        let identifiedSpeakers = speakers.values.filter { $0.isIdentified }.count
        let totalMeetings = speakers.values.reduce(0) { $0 + $1.meetingCount }
        let averageConfidence = speakers.values.isEmpty ? 0 : speakers.values.map { $0.confidence }.reduce(0, +) / Float(speakers.count)
        
        return SpeakerDatabaseStats(
            totalSpeakers: totalSpeakers,
            learnedSpeakers: learnedSpeakers,
            identifiedSpeakers: identifiedSpeakers,
            totalMeetings: totalMeetings,
            averageConfidence: averageConfidence
        )
    }
}

struct SpeakerDatabaseStats {
    let totalSpeakers: Int
    let learnedSpeakers: Int
    let identifiedSpeakers: Int
    let totalMeetings: Int
    let averageConfidence: Float
    
    var identificationRate: Float {
        return totalSpeakers > 0 ? Float(identifiedSpeakers) / Float(totalSpeakers) : 0
    }
    
    var learningRate: Float {
        return totalSpeakers > 0 ? Float(learnedSpeakers) / Float(totalSpeakers) : 0
    }
}