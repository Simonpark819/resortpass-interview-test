//
//  AppRoute.swift
//  SimonPass
//

import Foundation

/// Defines all possible navigation destinations in the app.
/// Add a new case here when a new screen is introduced —
/// the coordinator handles what each case resolves to.
enum AppRoute: Hashable {
    case hotelList(place: Place, latitude: Double, longitude: Double)
}
