import Foundation

/*
 Practice task: Meeting-room booking system

 Build an in-memory meeting-room booking system.

 Requirements
 - Create a booking with an ID, room ID, start time, and end time.
 - Reject an invalid booking when start is greater than or equal to end.
 - Reject a booking that overlaps an existing booking in the same room.
 - Allow back-to-back bookings: one ending at 10:00 and another starting at
   10:00 is valid.
 - Cancel a booking by its ID.
 - List a room's bookings ordered by start time.

 Assume all times are integer minutes since the start of the day. Keep
 everything in memory; no UI or persistence is needed.
*/

struct Booking {

    // MARK: Properties

    let id: UUID
    let roomNumber: Int
    let start: Date
    let end: Date

    // MARK: Init

    init(id: UUID = UUID(), roomNumber: Int, start: Date, end: Date) {
        self.id = id
        self.roomNumber = roomNumber
        self.start = start
        self.end = end
    }
}

// MARK: Error

enum BookingError: Error {

    case overlap
    case invalid
    case bookingNotFound
}

var bookingsByRoom: [Int: [Booking]] = [:]

@MainActor
func createBooking(roomNumber: Int, start: Date, end: Date) throws -> Booking {
    guard start < end else {
        throw BookingError.invalid
    }

    let bookings = bookingsByRoom[roomNumber] ?? []

    for booking in bookings {
        let overlaps = start < booking.end && end > booking.start

        if overlaps {
            throw BookingError.overlap
        }
    }

    let newBooking = Booking(roomNumber: roomNumber, start: start, end: end)
    bookingsByRoom[roomNumber, default: []].append(newBooking)
    return newBooking
}

@MainActor
func cancelBooking(id: UUID) throws {
    let allBookings = bookingsByRoom.values.flatMap { $0 }

    guard let booking = allBookings.first(where: { $0.id == id }) else {
        throw BookingError.bookingNotFound
    }

    bookingsByRoom[booking.roomNumber]?.removeAll { $0.id == id }
}

@MainActor
func bookings(for room: Int) -> [Booking] {
    guard var bookings = bookingsByRoom[room] else {
        return []
    }

    bookings.sort { first, second in
        first.start < second.start
    }

    return bookings
}
