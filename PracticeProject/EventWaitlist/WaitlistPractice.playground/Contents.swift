import Foundation

/*
 Practice task: Event RSVP system

 Build an in-memory RSVP system for events with limited capacity.

 Requirements
 - Create an event with a unique event ID, name, and positive capacity.
 - RSVP an attendee using an event ID and attendee ID.
 - An attendee may RSVP only once per event.
 - When an event is full, add new attendees to its waitlist in the order their
   RSVP requests were received.
 - Cancel an attendee's RSVP or waitlist entry using the event ID and attendee
   ID.
 - When a confirmed attendee cancels, automatically promote the first person
   on the waitlist. Cancelling someone already on the waitlist does not promote
   anyone.
 - Return an event's confirmed attendees, in RSVP order.
 - Return an event's waitlist, in order.
 - Return the number of seats still available for an event.
 - Reject requests for an event that does not exist.

 Example
 - Create an event with capacity 2.
 - RSVP A and B: both are confirmed.
 - RSVP C: C is added to the waitlist.
 - Cancel B: C becomes confirmed and the waitlist is empty.

 No UI, database, dates, notifications, or networking is needed.
 Start by defining your data model and the public methods you want to expose.
*/

struct Event {
    
    let id = UUID()
    let name: String
    let capacity: Int
    var attendeeList: [UUID] = []
    var waitlist: [UUID] = []
    
    var isAtCapacity: Bool {
        return availableSpace <= 0
    }
    
    var availableSpace: Int {
        return capacity - attendeeList.count
    }
    
}

struct Attendee {
    
    let id: UUID
    var rsvpList: [UUID] = []
    
    // Needs to check waitlist too
    func isAttendingEvent(eventID: UUID) -> Bool {
        return rsvpList.contains(where: { $0 == eventID })
    }
    
}

var events = [
    Event(name: "4th of July", capacity: 100),
    Event(name: "Duesey Days", capacity: 50),
    Event(name: "Emerson's Birthday", capacity: 20),
    Event(name: "Steven's Dinner Party", capacity: 40),
    Event(name: "Doyle's Retirement Party", capacity: 500)
]

var attendees: [Attendee] = []

func reserve(eventID: UUID, attendeeID: UUID) -> Bool {
    guard let index = events.firstIndex(where: { $0.id == eventID }) else {
        return false
    }
    
    var rsvpList: [UUID]
    if let existingAttendee = attendees.first(where: { $0.id == attendeeID }) {
        if existingAttendee.isAttendingEvent(eventID: eventID) {
            return false
        }
        
        rsvpList = existingAttendee.rsvpList
    } else {
        rsvpList = []
    }
    
    let addedToEvent: Bool
    if !events[index].isAtCapacity {
        rsvpList.append(events[index].id)
        events[index].attendeeList.append(attendeeID)
        addedToEvent = true
    } else {
        events[index].waitlist.append(attendeeID)
        addedToEvent = false
    }
    
    if let index = attendees.firstIndex(where: { $0.id == attendeeID }) {
        attendees[index].rsvpList = rsvpList
    } else {
        let newAttendee = Attendee(id: attendeeID, rsvpList: rsvpList)
        attendees.append(newAttendee)
    }
    
    return addedToEvent
}

func cancel(eventID: UUID, attendeeID: UUID) -> UUID? {
    guard let eventIndex = events.firstIndex(where: { $0.id == eventID }),
          let attendeeIndex = attendees.firstIndex(where: { $0.id == attendeeID }) else {
        return nil
    }
    
    guard !events[eventIndex].waitlist.contains(where: { $0 == attendeeID }) else {
        events[eventIndex].waitlist.removeAll(where: { $0 == attendeeID })
        return nil
    }
    
    if let rsvpIndex = events[eventIndex].attendeeList.firstIndex(where: { $0 == attendeeID }) {
        events[eventIndex].attendeeList.remove(at: rsvpIndex)
        attendees[attendeeIndex].rsvpList.removeAll(where: { $0 == eventID })
        
        return promoteAttendeeIfNeeded(eventIndex: eventIndex)
    } else {
        return nil
    }
}

func promoteAttendeeIfNeeded(eventIndex: Int) -> UUID? {
    if let promotedAttendee = events[eventIndex].waitlist.first {
        let didReserve = reserve(eventID: events[eventIndex].id, attendeeID: promotedAttendee)
        
        if didReserve {
            events[eventIndex].waitlist.removeFirst()
        }
        
        return didReserve ? promotedAttendee : nil
    } else {
        return nil
    }
}

func attendeeList(for eventID: UUID) -> [UUID]? {
    guard let event = events.first(where: { $0.id == eventID }) else {
        return nil
    }
    
    return event.attendeeList
}

func waitlist(for eventID: UUID) -> [UUID]? {
    guard let event = events.first(where: { $0.id == eventID }) else {
        return nil
    }
    
    return event.waitlist
}

func availableSpace(for eventID: UUID) -> Int? {
    guard let event = events.first(where: { $0.id == eventID }) else {
        return nil
    }
    
    return event.availableSpace
}
