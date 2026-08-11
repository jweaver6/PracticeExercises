import Foundation

/*
 Practice task: Bike-share rental system

 Build an in-memory system for a small bike-share service. The system manages
 bikes at stations and lets riders start and end rentals.

 Requirements
 - Add a station with a unique station ID and a non-negative dock capacity.
 - Add a bike with a unique bike ID at a station. Reject it if the bike ID
   already exists or the station has no available dock.
 - Start a rental using a rider ID and bike ID.
   - Reject it if the bike does not exist or is already rented.
   - Reject it if the rider already has an active rental.
   - Starting a rental removes the bike from its station and records the
     rental's start time.
 - End a rental using a rider ID, destination station ID, and end time.
   - Reject it if the rider has no active rental, the destination station does
     not exist, or that station is full.
   - Reject an end time earlier than the rental's start time.
   - Ending a rental returns the bike to the destination station and makes the
     rider available for another rental.
 - Return the available bikes at a station, in the order they arrived there.
 - Return a station's remaining dock capacity.
 - Return a rider's active rental, if any.

 Example
 - Station A has capacity 2; Station B has capacity 1.
 - Add bike X and Y to A.
 - Rider R starts a rental with X: A now has only Y.
 - Rider R ends at B: B now has X and R has no active rental.
 - A second rider cannot end a rental at B until X leaves B.

 Keep everything in memory. No UI, persistence, payments, reservations,
 GPS, or concurrency is needed.

 Suggested approach
 1. Clarify the states and invariants before coding.
 2. Define the data model and public API you want to expose.
 3. Implement the core operations, then cover error paths.
 4. If time remains, add a few focused test scenarios below.
*/

// Start here.

struct Station {
    
    let id = UUID()
    let capacity: UInt
    var availableBikes: [Bike] = []
    
    var isAtCapacity: Bool {
        return availableBikes.count == capacity
    }
    
}

struct Bike {
    
    let id = UUID()
    var startDate: Date?
    
}

struct Rider {
    
    let id: UUID
    var bike: Bike?
    
    func isRenting(bikeID: UUID) -> Bool {
        return bike?.id == bikeID
    }
    
}

var stations = [
    Station(capacity: 4),
    Station(capacity: 8),
    Station(capacity: 20),
    Station(capacity: 1),
    Station(capacity: 3)
]

var knownRiders: [Rider] = []

func add(to stationID: UUID, bike: Bike) {
    let bikeExistsWithCustomer = knownRiders.compactMap { $0.bike }.contains { $0.id == bike.id }
    let bikeExistsInStations = stations.contains { $0.availableBikes.contains { $0.id == bike.id } }
    
    guard let index = stations.firstIndex(where: { $0.id == stationID }),
          !stations[index].isAtCapacity,
          !bikeExistsWithCustomer,
          !bikeExistsInStations else {
        return
    }
    
    stations[index].availableBikes.append(bike)
}

func addStation(with capacity: UInt) {
    let station = Station(capacity: capacity)
    stations.append(station)
}

func rent(stationID: UUID, bikeID: UUID, riderID: UUID) {
    guard let stationIndex = stations.firstIndex(where: { $0.id == stationID }),
          var bike = stations[stationIndex].availableBikes.first(where: { $0.id == bikeID }) else {
        return
    }
    
    let riderIndex: Int?
    if let knownRiderIndex = knownRiders.firstIndex(where: { $0.id == riderID }) {
        guard knownRiders[knownRiderIndex].bike == nil else {
            return
        }
        
        riderIndex = knownRiderIndex
    } else {
        let rider = Rider(id: riderID)
        knownRiders.append(rider)
        riderIndex = knownRiders.firstIndex(where: { $0.id == rider.id })
    }
    
    if let riderIndex {
        bike.startDate = Date()
        knownRiders[riderIndex].bike = bike
        stations[stationIndex].availableBikes.removeAll(where: { $0.id == bike.id})
    }
}

func returnBike(with bikeID: UUID, stationID: UUID, riderID: UUID, endDate: Date) {
    guard let stationIndex = stations.firstIndex(where: { $0.id == stationID }),
          !stations[stationIndex].isAtCapacity,
          let riderIndex = knownRiders.firstIndex(where: { $0.id == riderID }),
          var bike = knownRiders[riderIndex].bike,
          let startDate = knownRiders[riderIndex].bike?.startDate,
          knownRiders[riderIndex].isRenting(bikeID: bikeID),
          endDate >= startDate else {
        return
    }

    bike.startDate = nil
    stations[stationIndex].availableBikes.append(bike)
    knownRiders[riderIndex].bike = nil
}

func capacity(at stationID: UUID) -> UInt? {
    guard let station = stations.first(where: { $0.id == stationID } ) else {
        return nil
    }
    
    return station.capacity - UInt(station.availableBikes.count)
}

func rental(for riderID: UUID) -> Bike? {
    guard let rider = knownRiders.first(where: { $0.id == riderID }) else {
        return nil
    }
    
    return rider.bike
}
