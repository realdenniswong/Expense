import SwiftUI
import MapKit
import CoreLocation
import Contacts

// Codable struct for recent locations
struct RecentLocation: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double?
    var longitude: Double?
}

// Enhanced LocationSearchView with MKLocalSearchCompleter
struct LocationSearchView: View {
    @Binding var selectedLocation: String?
    @Binding var selectedAddress: String?
    @Binding var selectedLatitude: Double?
    @Binding var selectedLongitude: Double?
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var searchCompletions: [MKLocalSearchCompletion] = []
    @State private var searchTask: Task<Void, Never>?
    @FocusState private var isSearchFocused: Bool
    @State private var showAllSuggestions = false
    
    // Current location
    @StateObject private var locationManager = SimpleLocationManager()
    @State private var isGettingCurrentLocation = false
    
    // Search completer for smart suggestions
    @StateObject private var searchCompleter = SearchCompleter()
    
    @AppStorage("recentLocations") private var recentLocationsData: Data = Data()
    @State private var recentLocations: [RecentLocation] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    
                    // Current Location Section
                    Section(header: Text("Location Search")) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search for a place or address", text: $searchText)
                                .textFieldStyle(.plain)
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                                .onSubmit {
                                    performFullSearch()
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            if isGettingCurrentLocation {
                                Text("Getting Current Location...")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text("Current Location")
                                
                                Spacer()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            getCurrentLocation()
                        }
                    }
                    
                    // Smart suggestions for short queries (1-2 chars)
                    if !searchCompletions.isEmpty {
                        Section {
                            ForEach(showAllSuggestions ? searchCompletions.prefix(10) : searchCompletions.prefix(3), id: \.self) { completion in
                                SearchCompletionRow(completion: completion) {
                                    selectCompletion(completion)
                                }
                            }
                        } header: {
                            HStack {
                                Text("Suggestions")
                                    .font(.headline)
                                Spacer()
                                if searchCompletions.count > 3 {
                                    Button(showAllSuggestions ? "Show Less" : "Show More") {
                                        showAllSuggestions.toggle()
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                    }
                    
                    // Direct search results for longer queries (3+ chars)
                    if !searchResults.isEmpty {
                        Section(header: Text("Places")) {
                            ForEach(searchResults, id: \.self) { mapItem in
                                LocationResultRow(mapItem: mapItem) {
                                    selectLocation(mapItem)
                                }
                            }
                        }
                    }
                    
                    // Recent Locations Section
                    if !recentLocations.isEmpty {
                        Section(header:
                            HStack {
                                Text("Recent Locations")
                                Spacer()
                                if !recentLocations.isEmpty {
                                    Button("Clear All") {
                                        recentLocations.removeAll()
                                        saveRecentLocations()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }
                        ) {
                            ForEach(recentLocations) { recent in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recent.name)
                                        .font(.body)
                                        .lineLimit(1)
                                    Text(recent.address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectRecentLocation(recent)
                                }
                            }
                            .onDelete(perform: deleteRecentLocations)
                        }
                    }
                    
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Allows custom text as location if not an exact result, like Calendar app
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Always save plain text unless user taps a suggestion/result.
                        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            selectedLocation = trimmed
                            selectedAddress = trimmed
                            selectedLatitude = nil
                            selectedLongitude = nil
                            addRecentLocation(name: trimmed, address: trimmed, latitude: nil, longitude: nil)
                            dismiss()
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    searchCompletions = []
                    searchResults = []
                    searchCompleter.queryFragment = ""
                } else {
                    searchCompleter.queryFragment = newValue
                    searchWithDelay()
                }
            }
            .onAppear {
                loadRecentLocations()
                // Start getting location immediately
                locationManager.requestLocationPermission()
                
                // Set initial region for search completer
                setupSearchCompleterRegion()
                
                // Auto-focus search field like Calendar app
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isSearchFocused = true
                }
            }
            .onReceive(locationManager.$currentLocation) { location in
                // Update search completer region when location changes
                setupSearchCompleterRegion()
                // Also update the completer's location for sorting
                searchCompleter.setLocation(location)
            }
            .onReceive(searchCompleter.$completions) { completions in
                searchCompletions = completions
            }
        }
    }
    
    // MARK: - Helper to check if searchText is already a result
    
    private func isSearchTextAlreadyAResult() -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        print("[DEBUG] Search text (trimmed, lowered): '\(trimmed)'")
        if trimmed.isEmpty { 
            print("[DEBUG] Search text is empty after trimming")
            return true 
        }
        if let matched = searchResults.first(where: { 
            let nameLower = ($0.name ?? "").lowercased()
            let match = nameLower == trimmed
            if match { print("[DEBUG] Matched in searchResults: \($0.name ?? "")") }
            return match
        }) {
            return true
        }
        if let matched = searchCompletions.first(where: {
            let titleLower = $0.title.lowercased()
            let match = titleLower == trimmed
            if match { print("[DEBUG] Matched in searchCompletions: \($0.title)") }
            return match
        }) {
            return true
        }
        if let matched = recentLocations.first(where: {
            let nameLower = $0.name.lowercased()
            let addressLower = $0.address.lowercased()
            let match = nameLower == trimmed && addressLower == trimmed
            if match { print("[DEBUG] Matched in recentLocations: \($0.name) / \($0.address)") }
            return match
        }) {
            return true
        }
        print("[DEBUG] No match for '\(trimmed)'")
        return false
    }
    
    // MARK: - Recent Locations Storage
    
    private func loadRecentLocations() {
        do {
            let decoded = try JSONDecoder().decode([RecentLocation].self, from: recentLocationsData)
            recentLocations = decoded
        } catch {
            recentLocations = []
        }
    }
    
    private func saveRecentLocations() {
        do {
            let encoded = try JSONEncoder().encode(recentLocations)
            recentLocationsData = encoded
        } catch {
            print("Failed to save recent locations: \(error)")
        }
    }
    
    private func addRecentLocation(name: String, address: String, latitude: Double? = nil, longitude: Double? = nil) {
        // If the location already exists, remove it to put it on top
        if let index = recentLocations.firstIndex(where: { $0.name == name && $0.address == address }) {
            recentLocations.remove(at: index)
        }
        // Prevent duplicate manual entries where name == address
        if name == address {
            if recentLocations.contains(where: { $0.name == name && $0.address == address }) {
                // Already exists, don't insert again
                saveRecentLocations()
                return
            }
        }
        // Insert new location at the front
        let newRecent = RecentLocation(id: UUID(), name: name, address: address, latitude: latitude, longitude: longitude)
        recentLocations.insert(newRecent, at: 0)
        
        // Limit max number of recent locations to 8
        if recentLocations.count > 8 {
            recentLocations = Array(recentLocations.prefix(8))
        }
        
        saveRecentLocations()
    }
    
    private func deleteRecentLocations(at offsets: IndexSet) {
        recentLocations.remove(atOffsets: offsets)
        saveRecentLocations()
    }
    
    // MARK: - Search Functions
    
    private func searchWithDelay() {
        // Cancel previous search
        searchTask?.cancel()
        
        // Search immediately for any non-empty query
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        print("Starting full search for: '\(searchText)'")
        
        // Search with delay for full results
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            if !Task.isCancelled {
                await performFullSearch()
            }
        }
    }
    
    @MainActor
    private func performFullSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        print("Performing full search for: '\(searchText)'")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = [.pointOfInterest, .address]
        
        // Use tighter search radius for closer results
        if let location = locationManager.currentLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 20000, // Reduced to 20km
                longitudinalMeters: 20000
            )
        } else {
            // Smaller default region
            let hongKongCoordinate = CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694)
            request.region = MKCoordinateRegion(
                center: hongKongCoordinate,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            Task { @MainActor in
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    self.searchResults = []
                    return
                }
                
                if let mapItems = response?.mapItems {
                    print("Found \(mapItems.count) search results")
                    
                    // Filter out results that are too far (optional)
                    let filteredItems: [MKMapItem]
                    if let userLocation = self.locationManager.currentLocation {
                        filteredItems = mapItems.filter { item in
                            let itemLocation = CLLocation(
                                latitude: item.placemark.coordinate.latitude,
                                longitude: item.placemark.coordinate.longitude
                            )
                            let distance = userLocation.distance(from: itemLocation)
                            return distance <= 15000 // Only show results within 15km
                        }
                        
                        self.searchResults = filteredItems.sorted { item1, item2 in
                            let location1 = CLLocation(
                                latitude: item1.placemark.coordinate.latitude,
                                longitude: item1.placemark.coordinate.longitude
                            )
                            let location2 = CLLocation(
                                latitude: item2.placemark.coordinate.latitude,
                                longitude: item2.placemark.coordinate.longitude
                            )
                            return userLocation.distance(from: location1) < userLocation.distance(from: location2)
                        }
                    } else {
                        self.searchResults = mapItems
                    }
                    
                    print("Final search results count: \(self.searchResults.count)")
                } else {
                    print("No search results found")
                    self.searchResults = []
                }
            }
        }
    }
    
    // MARK: - Selection Functions
    
    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        // Search for the selected completion
        let request = MKLocalSearch.Request(completion: completion)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                if let mapItem = response?.mapItems.first {
                    selectLocation(mapItem)
                }
            }
        }
    }
    
    private func getCurrentLocation() {
        isGettingCurrentLocation = true
        
        locationManager.requestCurrentLocation { location, placemark in
            DispatchQueue.main.async {
                isGettingCurrentLocation = false
                
                if let placemark = placemark {
                    let locationName = placemark.name ?? "Current Location"
                    let address = formatAddress(from: placemark)
                    
                    selectedLocation = locationName
                    selectedAddress = address
                    if let location = location {
                        selectedLatitude = location.coordinate.latitude
                        selectedLongitude = location.coordinate.longitude
                    } else {
                        selectedLatitude = nil
                        selectedLongitude = nil
                    }
                    // Add current location to recent locations as well
                    addRecentLocation(name: locationName, address: address, latitude: location?.coordinate.latitude, longitude: location?.coordinate.longitude)
                    dismiss()
                } else if let location = location {
                    let locString = String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
                    selectedLocation = "Current Location"
                    selectedAddress = locString
                    selectedLatitude = location.coordinate.latitude
                    selectedLongitude = location.coordinate.longitude
                    // Add current location to recent locations as well
                    addRecentLocation(name: "Current Location", address: locString, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    dismiss()
                } else {
                    selectedLatitude = nil
                    selectedLongitude = nil
                }
            }
        }
    }
    
    private func selectLocation(_ mapItem: MKMapItem) {
        let name = mapItem.name ?? "Unknown Location"
        let address = mapItem.placemark.title ?? formatAddress(from: mapItem.placemark)
        
        selectedLocation = name
        selectedAddress = address
        selectedLatitude = mapItem.placemark.coordinate.latitude
        selectedLongitude = mapItem.placemark.coordinate.longitude
        addRecentLocation(name: name, address: address, latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
        dismiss()
    }
    
    private func selectRecentLocation(_ recent: RecentLocation) {
        selectedLocation = recent.name
        selectedAddress = recent.address
        selectedLatitude = recent.latitude
        selectedLongitude = recent.longitude
        dismiss()
    }
    
    private func setupSearchCompleterRegion() {
        if let location = locationManager.currentLocation {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 20000, // 20km radius
                longitudinalMeters: 20000
            )
            searchCompleter.region = region
        } else {
            // Don't set any default region - let Apple's search handle it globally
            // This avoids hardcoding any specific location
            searchCompleter.region = nil
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        let formatter = CNPostalAddressFormatter()
        
        if let postalAddress = placemark.postalAddress {
            return formatter.string(from: postalAddress)
                .replacingOccurrences(of: "\n", with: ", ")
        }
        
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.isEmpty ? "Unknown Address" : components.joined(separator: ", ")
    }
}

// MARK: - Search Completer

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var completions: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    private var currentLocation: CLLocation?
    
    var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    
    var region: MKCoordinateRegion? {
        didSet {
            completer.region = region ?? MKCoordinateRegion()
        }
    }
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
    }
    
    func setLocation(_ location: CLLocation?) {
        currentLocation = location
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            // Sort completions by distance if we have user location
            if let userLocation = self.currentLocation {
                let sortedCompletions = completer.results.sorted { completion1, completion2 in
                    // Get approximate distance based on completion coordinates (if available)
                    let distance1 = self.approximateDistance(from: userLocation, to: completion1)
                    let distance2 = self.approximateDistance(from: userLocation, to: completion2)
                    return distance1 < distance2
                }
                self.completions = sortedCompletions
            } else {
                // No location - use default order
                self.completions = completer.results
            }
        }
    }
    
    private func approximateDistance(from userLocation: CLLocation, to completion: MKLocalSearchCompletion) -> CLLocationDistance {
        // MKLocalSearchCompletion doesn't have coordinates directly
        // But we can use the subtitle to get approximate location info
        
        // For now, we rely on Apple's built-in sorting when region is set
        // This is a placeholder - Apple's completer should already sort by relevance/distance
        return 0
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}

// MARK: - Search Completion Row

struct SearchCompletionRow: View {
    let completion: MKLocalSearchCompletion
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                // Highlight the matching part
                Text(attributedTitle)
                    .font(.body)
                    .lineLimit(1)
                
                if !completion.subtitle.isEmpty {
                    Text(attributedSubtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var attributedTitle: AttributedString {
        var attributed = AttributedString(completion.title)
        
        // Highlight the matching ranges
        for rangeValue in completion.titleHighlightRanges {
            let range = rangeValue.rangeValue
            guard range.location != NSNotFound,
                  range.location + range.length <= completion.title.count else { continue }
            
            let start = attributed.index(attributed.startIndex, offsetByCharacters: range.location)
            let end = attributed.index(start, offsetByCharacters: range.length)
            attributed[start..<end].font = .body.weight(.semibold)
        }
        
        return attributed
    }
    
    private var attributedSubtitle: AttributedString {
        var attributed = AttributedString(completion.subtitle)
        
        // Highlight the matching ranges
        for rangeValue in completion.subtitleHighlightRanges {
            let range = rangeValue.rangeValue
            guard range.location != NSNotFound,
                  range.location + range.length <= completion.subtitle.count else { continue }
            
            let start = attributed.index(attributed.startIndex, offsetByCharacters: range.location)
            let end = attributed.index(start, offsetByCharacters: range.length)
            attributed[start..<end].font = .caption.weight(.semibold)
        }
        
        return attributed
    }
}

// MARK: - Location Result Row (same as before)

struct LocationResultRow: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    private var subtitle: String {
        // Always show address as subtitle (like Apple Maps)
        let formatter = CNPostalAddressFormatter()
        if let postalAddress = mapItem.placemark.postalAddress {
            return formatter.string(from: postalAddress)
                .replacingOccurrences(of: "\n", with: ", ")
        }
        
        // Fallback to constructing address from components
        var addressComponents: [String] = []
        
        if let thoroughfare = mapItem.placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let locality = mapItem.placemark.locality {
            addressComponents.append(locality)
        }
        if let administrativeArea = mapItem.placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        let address = addressComponents.joined(separator: ", ")
        return address.isEmpty ? (mapItem.placemark.title ?? "") : address
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon based on type
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mapItem.name ?? "Unknown")
                    .font(.body)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var iconName: String {
        // Debug: Let's see what category we're getting
        print("MapItem: \(mapItem.name ?? "Unknown"), Category: \(mapItem.pointOfInterestCategory?.rawValue ?? "nil")")
        
        // Use category-specific icons based on POI category
        if let category = mapItem.pointOfInterestCategory {
            switch category {
            case .restaurant:
                return "fork.knife"
            case .hotel:
                return "bed.double"
            case .gasStation:
                return "fuelpump"
            case .hospital:
                return "cross"
            case .pharmacy:
                return "pills"
            case .store:
                return "bag"
            case .school:
                return "graduationcap"
            case .museum:
                return "building.columns"
            case .library:
                return "books.vertical"
            case .park:
                return "tree"
            case .theater:
                return "theatermasks"
            case .bank:
                return "banknote"
            case .airport:
                return "airplane"
            case .atm:
                return "creditcard"
            case .bakery:
                return "birthday.cake"
            case .brewery:
                return "wineglass"
            case .cafe:
                return "cup.and.saucer"
            case .campground:
                return "tent"
            case .carRental:
                return "car"
            case .evCharger:
                return "bolt.car"
            case .fitnessCenter:
                return "dumbbell"
            case .foodMarket:
                return "cart"
            case .laundry:
                return "washer"
            case .marina:
                return "sailboat"
            case .movieTheater:
                return "tv"
            case .nightlife:
                return "music.note"
            case .parking:
                return "parkingsign"
            case .postOffice:
                return "envelope"
            case .publicTransport:
                return "bus"
            case .restroom:
                return "figure.walk"
            case .stadium:
                return "sportscourt"
            case .zoo:
                return "pawprint"
            default:
                return "mappin.and.ellipse"
            }
        } else {
            // No POI category - this is likely the issue
            print("No POI category found for: \(mapItem.name ?? "Unknown")")
            
            // Fallback based on name
            if let name = mapItem.name?.lowercased() {
                if name.contains("mcdonald") || name.contains("restaurant") || name.contains("burger") {
                    return "fork.knife"
                } else if name.contains("coffee") || name.contains("starbucks") {
                    return "cup.and.saucer"
                } else if name.contains("hotel") {
                    return "bed.double"
                } else if name.contains("gas") || name.contains("petrol") {
                    return "fuelpump"
                } else if name.contains("bank") {
                    return "banknote"
                } else if name.contains("hospital") {
                    return "cross"
                }
            }
            
            return "mappin.and.ellipse"  // Default for places
        }
    }
    
    private var iconColor: Color {
        // Use category-specific colors
        if let category = mapItem.pointOfInterestCategory {
            switch category {
            case .restaurant, .cafe, .bakery:
                return .orange
            case .hotel:
                return .blue
            case .gasStation:
                return .green
            case .hospital, .pharmacy:
                return .red
            case .store, .foodMarket:
                return .purple
            case .school, .library:
                return .blue
            case .park:
                return .green
            case .bank, .atm:
                return .green
            default:
                return .red
            }
        } else {
            return .blue
        }
    }
}

// MARK: - Simple Location Manager (same as before)

class SimpleLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    private var locationCompletion: ((CLLocation?, CLPlacemark?) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocationPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func requestCurrentLocation(completion: @escaping (CLLocation?, CLPlacemark?) -> Void) {
        locationCompletion = completion
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            completion(nil, nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        
        // Handle completion if there's one pending
        if let completion = locationCompletion {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                completion(location, placemarks?.first)
                self?.locationCompletion = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(nil, nil)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

// MARK: - SimpleLocationManager Early Prewarm Extension

extension SimpleLocationManager {
    static let shared = SimpleLocationManager() // singleton for early access
    static func prewarmLocation() {
        shared.requestLocationPermission()
    }
}
