//
//  SpotlightDataSource.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

/// Protocollo per fornire dati allo spotlight
public protocol SpotlightDataSource: Sendable {
	associatedtype Item: SpotlightItem
	
	func search(query: String) async -> [Item]
	func allItems() async -> [Item]
}
