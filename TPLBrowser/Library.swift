
import Foundation
import CoreLocation

struct Library: Codable, Identifiable {
    let id: Int
    let branchCode, branchName, address, postalCode: String
    let website: String
    let telephone, squareFootage, publicParking: String
    let kidsStop, leadingReading, clc, dih: Int?
    let teenCouncil, youthHub, adultLiteracyProgram, workstations: Int?
    let serviceTier: String
    let lat: String
    let long: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double(lat) ?? 0.0, longitude: Double(long) ?? 0.0)
    }

    let nbhdNo: Int?
    let nbhdName: String?
    let tplnia, wardNo: Int?
    let wardName: String
    let presentSiteYear: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case branchCode = "BranchCode"
        case branchName = "BranchName"
        case address = "Address"
        case postalCode = "PostalCode"
        case website = "Website"
        case telephone = "Telephone"
        case squareFootage = "SquareFootage"
        case publicParking = "PublicParking"
        case kidsStop = "KidsStop"
        case leadingReading = "LeadingReading"
        case clc = "CLC"
        case dih = "DIH"
        case teenCouncil = "TeenCouncil"
        case youthHub = "YouthHub"
        case adultLiteracyProgram = "AdultLiteracyProgram"
        case workstations = "Workstations"
        case serviceTier = "ServiceTier"
        case lat = "Lat"
        case long = "Long"
        case nbhdNo = "NBHDNo"
        case nbhdName = "NBHDName"
        case tplnia = "TPLNIA"
        case wardNo = "WardNo"
        case wardName = "WardName"
        case presentSiteYear = "PresentSiteYear"
    }
}

