import Foundation

class TimeConverterViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var result: String = ""
    @Published var errorMessage: String = ""
    @Published var selectedTimeZone: TimeZone = TimeZone.current
    
    let availableTimeZones: [TimeZone]
    private let dateFormatter: DateFormatter
    
    init() {
        // Get all available timezones
        self.availableTimeZones = TimeZone.knownTimeZoneIdentifiers.compactMap { TimeZone(identifier: $0) }
        
        // Initialize date formatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func convert() {
        errorMessage = ""
        result = ""
        
        // Clean input
        let cleanInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to parse timestamp
        if let timestampNum = Double(cleanInput) {
            let timestamp: Double
            
            // Determine if input is in nanoseconds, microseconds, or seconds
            if timestampNum > 1_000_000_000_000_000 {  // Nanoseconds (> 2001 year)
                timestamp = timestampNum / 1_000_000_000
            } else if timestampNum > 1_000_000_000_000 {  // Microseconds
                timestamp = timestampNum / 1_000_000
            } else {  // Seconds
                timestamp = timestampNum
            }
            
            let date = Date(timeIntervalSince1970: timestamp)
            dateFormatter.timeZone = selectedTimeZone
            
            // Format result with all timestamp versions
            let nanos = Int64(timestamp * 1_000_000_000)
            let micros = Int64(timestamp * 1_000_000)
            let millis = Int64(timestamp * 1_000)
            let seconds = Int64(timestamp)
            
            result = """
                Date: \(dateFormatter.string(from: date))
                Timestamp (ns):  \(nanos)
                Timestamp (μs):  \(micros)
                Timestamp (ms):  \(millis)
                Timestamp (s):   \(seconds)
                """
            return
        }
        
        // Try to parse datetime string with flexible format
        if let dates = parseFlexibleDateTime(cleanInput) {
            result = dates.map { date in
                let timestamp = date.timeIntervalSince1970
                let nanos = Int64(timestamp * 1_000_000_000)
                let micros = Int64(timestamp * 1_000_000)
                let millis = Int64(timestamp * 1_000)
                let seconds = Int64(timestamp)
                
                dateFormatter.timeZone = selectedTimeZone
                return """
                    Date: \(dateFormatter.string(from: date))
                    Timestamp (ns):  \(nanos)
                    Timestamp (μs):  \(micros)
                    Timestamp (ms):  \(millis)
                    Timestamp (s):   \(seconds)
                    """
            }.joined(separator: "\n\n")
            return
        }
        
        errorMessage = "Invalid input format. Please enter a timestamp or date in YYYY-MM-DD [HH[:MM[:SS]]] format"
    }
    
    private func parseFlexibleDateTime(_ input: String) -> [Date]? {
        // Regular expression to match date with optional time components
        let pattern = #"^(\d{4})-(\d{2})-(\d{2})(?:\s+(\d{1,2})(?::(\d{1,2}))?(?::(\d{1,2}))?)?$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }
        
        // Extract components
        let groups = (0...6).map { groupIdx -> String? in
            guard let range = Range(match.range(at: groupIdx), in: input) else { return nil }
            return String(input[range])
        }
        
        guard let yearStr = groups[1],
              let monthStr = groups[2],
              let dayStr = groups[3],
              let year = Int(yearStr),
              let month = Int(monthStr),
              let day = Int(dayStr) else {
            return nil
        }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = selectedTimeZone
        
        // If hour is provided, use it; otherwise return both 8:30 and 15:00
        if let hourStr = groups[4], let hour = Int(hourStr) {
            components.hour = hour
            components.minute = Int(groups[5] ?? "0")
            components.second = Int(groups[6] ?? "0")
            
            if let date = Calendar.current.date(from: components) {
                return [date]
            }
        } else {
            // Return both 8:30 and 15:00 times
            var dates: [Date] = []
            
            // Morning time (8:30)
            components.hour = 8
            components.minute = 30
            components.second = 0
            if let morningDate = Calendar.current.date(from: components) {
                dates.append(morningDate)
            }
            
            // Afternoon time (15:00)
            components.hour = 15
            components.minute = 0
            if let afternoonDate = Calendar.current.date(from: components) {
                dates.append(afternoonDate)
            }
            
            return dates.isEmpty ? nil : dates
        }
        
        return nil
    }
} 