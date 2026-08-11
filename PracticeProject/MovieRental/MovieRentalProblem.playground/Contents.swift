import UIKit

/*
 Practice task: Movie-rental system

 Build an in-memory movie-rental system.

 Requirements
 - Add a movie title with a unique movie ID, title, and number of copies.
 - Rent a copy to a customer using a movie ID and customer ID.
 - Return a rental using its rental ID.
 - Each rental receives a unique ID when created.
 - Reject renting a movie that does not exist or has no available copies.
 - Reject returning a rental that does not exist or was already returned.
 - Provide the number of available copies for a movie.
 - Provide a customer's active rentals.

 No UI, database, dates, networking, or full customer model is needed.
*/

struct Movie {
    
    let id = UUID()
    let title: String
    var numberOfCopies: Int
    
}

struct Rental {
    
    let id = UUID()
    let movieID: UUID
    
}

struct Customer {
    
    let id = UUID()
    var activeRentals: [Rental]
    
}

var availableMovies: [Movie] = [
    Movie(title: Constants.matrix, numberOfCopies: 2),
    Movie(title: Constants.odyssey, numberOfCopies: 5),
    Movie(title: Constants.dune, numberOfCopies: 1),
    Movie(title: Constants.spiderManBND, numberOfCopies: 9)
]

var customers: [Customer] = []

@MainActor
func rentMovie(to customer: Customer, movieID: UUID) -> UUID? {
    guard let index = availableMovies.firstIndex(where: { $0.id == movieID }) else {
        return nil
    }
    
    if availableMovies[index].numberOfCopies > 0 {
        let rental = Rental(movieID: availableMovies[index].id)
        availableMovies[index].numberOfCopies -= 1
        
        return addRental(to: customer, rental: rental)
    } else {
        return nil
    }
}

@MainActor
func addRental(to customer: Customer, rental: Rental) -> UUID {
    if let index = customers.firstIndex(where: { $0.id == customer.id }) {
        customers[index].activeRentals.append(rental)
    } else {
        var newCustomer = customer
        newCustomer.activeRentals.append(rental)
        customers.append(newCustomer)
    }
    
    return rental.id
}

@MainActor
func returnMovie(rentalID: UUID) -> Bool {
    guard let customerIndex = customers.firstIndex(where: { $0.activeRentals.contains(where: { $0.id == rentalID }) }),
          let rentalIndex = customers[customerIndex].activeRentals.firstIndex(where: { $0.id == rentalID }),
          let inventoryIndex = getAvailableMovieIndex(customerIndex: customerIndex, rentalID: rentalID) else {
        return false
    }
    
    customers[customerIndex].activeRentals.remove(at: rentalIndex)
    availableMovies[inventoryIndex].numberOfCopies += 1
    
    return true
}

@MainActor
func getAvailableMovieIndex(customerIndex: Int, rentalID: UUID) -> Int? {
    return availableMovies.firstIndex(where: { $0.id == customers[customerIndex].activeRentals.first(where: { $0.id == rentalID })?.movieID })
}

@MainActor
func addMovie(title: String, copies: Int) -> Movie {
    let movie = Movie(title: title, numberOfCopies: copies)
    availableMovies.append(movie)
    return movie
}

@MainActor
func copies(for movieID: UUID) -> Int {
    return availableMovies.first(where: { $0.id == movieID})?.numberOfCopies ?? 0
}

@MainActor
func numberOfRentals(for customerID: UUID) -> [Rental]? {
    return customers.first(where: { $0.id == customerID })?.activeRentals
}

enum Constants {
    
    static let matrix = "The Matrix"
    static let odyssey = "The Odyssey"
    static let dune = "Dune"
    static let spiderManBND = "Spider-Man: Brand New Day"
    
}
