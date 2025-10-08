//
//  LocationStorageTests.swift
//  LifeSpaceTests
//
//  Created by Vishnu Ravi on 2/7/25.
//

import CoreLocation
@testable import LifeSpace
import Testing

@Suite("LocationStorage Tests")
struct LocationStorageTests {
    var locationStorage: LocationStorage

    init() async throws {
        locationStorage = LocationStorage()
    }
    
    @Test("Initial state has empty locations and nil lastSaved")
    func initialState() async {
        let locations = await locationStorage.getAllLocations()
        #expect(locations.isEmpty, "Initial locations array should be empty")

        let lastSaved = await locationStorage.getLastSaved()
        #expect(lastSaved == nil, "Initial lastSaved should be nil")
    }
    
    @Test("Append location adds one location with correct coordinates")
    func appendLocation() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        await locationStorage.appendLocation(coordinate)

        let locations = await locationStorage.getAllLocations()
        #expect(locations.count == 1, "Should have one location after append")

        let firstLocation = try #require(locations.first, "Location should exist")
        #expect(abs(firstLocation.latitude - coordinate.latitude) < 0.0001)
        #expect(abs(firstLocation.longitude - coordinate.longitude) < 0.0001)
    }
    
    @Test("Update all locations replaces existing locations")
    func updateAllLocations() async {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        ]

        await locationStorage.updateAllLocations(coordinates)
        let locations = await locationStorage.getAllLocations()

        #expect(locations.count == coordinates.count)

        for (index, stored) in locations.enumerated() {
            let original = coordinates[index]
            #expect(abs(stored.latitude - original.latitude) < 0.0001)
            #expect(abs(stored.longitude - original.longitude) < 0.0001)
        }
    }
    
    @Test("Clear all locations removes all locations")
    func clearAllLocations() async {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        ]
        await locationStorage.updateAllLocations(coordinates)

        await locationStorage.clearAllLocations()
        let locations = await locationStorage.getAllLocations()

        #expect(locations.isEmpty, "Locations should be empty after clearing")
    }
    
    @Test("Update and get last saved location")
    func updateAndGetLastSaved() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let date = Date()

        await locationStorage.updateLastSaved(location: coordinate, date: date)
        let lastSaved = await locationStorage.getLastSaved()

        let unwrappedLastSaved = try #require(lastSaved)
        #expect(abs(unwrappedLastSaved.location.latitude - coordinate.latitude) < 0.0001)
        #expect(abs(unwrappedLastSaved.location.longitude - coordinate.longitude) < 0.0001)
        #expect(unwrappedLastSaved.date == date)
    }
    
    @Test("Multiple location appends preserves order and accuracy")
    func multipleLocationAppends() async {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
            CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        ]

        for coordinate in coordinates {
            await locationStorage.appendLocation(coordinate)
        }

        let locations = await locationStorage.getAllLocations()
        #expect(locations.count == coordinates.count)

        for (index, stored) in locations.enumerated() {
            let original = coordinates[index]
            #expect(abs(stored.latitude - original.latitude) < 0.0001)
            #expect(abs(stored.longitude - original.longitude) < 0.0001)
        }
    }
}
