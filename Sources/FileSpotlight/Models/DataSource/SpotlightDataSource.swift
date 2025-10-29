//
//  SpotlightDataSource.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

/// A protocol that defines a standard interface for providing searchable data to a spotlight component.
///
/// Conforming types act as a data source, responsible for fetching and filtering items based on a search query.
/// The protocol is `Sendable`, ensuring that conforming types can be safely used across concurrent contexts,
/// which is essential for performing asynchronous search operations without blocking the UI.
public protocol SpotlightDataSource: Sendable {
	/// The specific type of `SpotlightItem` that this data source provides.
	/// This allows the data source to be generic over any model that conforms to `SpotlightItem`.
	associatedtype Item: SpotlightItem
	
	/// Asynchronously performs a search for items that match a given query.
	///
	/// - Parameter query: The text string to use for filtering the items.
	/// - Returns: An array of `Item` objects that match the search query.
	func search(query: String) async -> [Item]
	
	/// Asynchronously fetches all available items from the data source without any filtering.
	///
	/// This method can be used to retrieve the entire dataset when needed, for example, to show an initial list
	/// before the user has started typing a query.
	///
	/// - Returns: An array containing all `Item` objects available from the data source.
	func allItems() async -> [Item]
}
