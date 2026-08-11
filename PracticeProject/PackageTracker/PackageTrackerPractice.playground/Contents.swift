import Foundation

/*
 Practice task: Parcel locker system

 Design and implement an in-memory system for a package locker wall.

 Requirements
 - Add lockers with a unique ID and size: small, medium, or large.
 - Store a package with a unique package ID, recipient ID, and package size.
 - When storing a package, assign the smallest available locker that fits it.
   A small package fits in small, medium, or large; a medium package fits in
   medium or large; a large package fits only in a large locker.
 - Reject a package when its ID already exists or no fitting locker is empty.
 - Pick up a package by package ID. This frees its locker.
 - Return the locker ID for a stored package.
 - Return the number of available lockers for each size.

 Example
 - Lockers: S1 (small), M1 (medium), L1 (large)
 - Store a small package: it goes into S1.
 - Store a medium package: it goes into M1.
 - Store another medium package: it goes into L1.
 - Pick up the first package: S1 becomes available again.

 No UI, database, dates, networking, or full recipient model is needed.
 Start by defining your data model and the public methods you want to expose.
*/

struct Locker {
    
    let id = UUID()
    let size: Size
    var package: Package?
    
}

struct Package {
    
    let id = UUID()
    let recipientID = UUID()
    let size: Size
    
}

enum Size: UInt8 {
    
    case small = 1
    case medium = 2
    case large = 3
    
}

var lockers = [
    Locker(size: .small),
    Locker(size: .small),
    Locker(size: .small),
    Locker(size: .medium),
    Locker(size: .medium),
    Locker(size: .medium),
    Locker(size: .medium),
    Locker(size: .large),
    Locker(size: .large)
]

func addLocker(size: Size) {
    let newLocker = Locker(size: size)
    lockers.append(newLocker)
}

func store(package: Package) -> UUID? {
    guard let id = getAvailableLockerID(with: package.size),
          let index = lockers.firstIndex(where: { $0.id == id }),
          getLockerID(for: package.id) == nil else {
        return nil
    }
    
    lockers[index].package = package
    return lockers[index].id
}

func pickup(packageID: UUID) -> Package? {
    guard let index = lockers.firstIndex(where: { $0.package?.id == packageID}),
          let package = lockers[index].package else {
        return nil
    }
    
    lockers[index].package = nil
    return package
}

func getLockerID(for packageID: UUID) -> UUID? {
    return lockers.first(where: { $0.package?.id == packageID })?.id
}

func numberOfEmtpyLockers(for size: Size) -> Int {
    return lockers.filter { ($0.size == size && $0.package == nil) }.count
}

func getAvailableLockerID(with size: Size) -> UUID? {
    let sortedLockers = lockers.sorted(by: { $0.size.rawValue < $1.size.rawValue })
    return sortedLockers.first(where: { ($0.size.rawValue >= size.rawValue && $0.package == nil) })?.id
}
