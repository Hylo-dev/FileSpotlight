//
//  SpotlightBuilder.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// A builder class that uses a fluent interface to simplify the configuration and creation of a spotlight view model.
///
/// This builder follows the builder pattern, allowing for method chaining to set up the data source,
/// sections, and styling before constructing the final `CustomSpotlightViewModel`.
/// It is marked as `@MainActor` because it configures UI-related components that should be handled on the main thread.
@MainActor
public class SpotlightBuilder<Item: SpotlightItem> {
	
	// MARK: - Private Properties
	
	/// The data source that will provide items for the spotlight search. It's type-erased to `any SpotlightDataSource`.
	private var dataSource: (any SpotlightDataSource)?
	
	/// An array of custom sections to be included in the spotlight.
	private var sections: [SpotlightSection<Item>] = []
	
	/// The overall configuration for the spotlight's behavior and appearance.
	private var configuration = SpotlightConfiguration.default
	
	/// The style configuration for the individual result rows.
	private var rowStyle = SpotlightRowStyle.default
	
	// MARK: - Initializer
	
	/// Creates a new, empty spotlight builder.
	public init() {}
	
	// MARK: - Configuration Methods
	
	/// Sets the data source for the spotlight.
	/// - Parameter dataSource: An object conforming to `SpotlightDataSource` that will provide the searchable items.
	/// - Returns: The builder instance (`Self`) to allow for method chaining.
	public func withDataSource<DS: SpotlightDataSource>(_ dataSource: DS) -> Self where DS.Item == Item {
		self.dataSource = dataSource
		
		return self
	}
	
	/// Adds a custom section to the spotlight.
	/// - Parameter section: A `SpotlightSection` to add.
	/// - Returns: The builder instance (`Self`) to allow for method chaining.
	public func withSection(_ section: SpotlightSection<Item>) -> Self {
		sections.append(section)
		
		return self
	}
	
	/// Sets the main configuration for the spotlight.
	/// - Parameter configuration: A `SpotlightConfiguration` object with settings for behavior and appearance.
	/// - Returns: The builder instance (`Self`) to allow for method chaining.
	public func withConfiguration(_ configuration: SpotlightConfiguration) -> Self {
		self.configuration = configuration
		
		return self
	}
	
	/// Sets the style for the result rows.
	/// - Parameter style: A `SpotlightRowStyle` object that defines the look of each row.
	/// - Returns: The builder instance (`Self`) to allow for method chaining.
	public func withRowStyle(_ style: SpotlightRowStyle) -> Self {
		self.rowStyle = style
		
		return self
	}
	
	// MARK: - Build Method
	
	/// Constructs and returns a `CustomSpotlightViewModel` with the specified configuration.
	///
	/// This method should be called at the end of the configuration chain.
	/// - Returns: A fully configured `CustomSpotlightViewModel` instance.
	public func build() -> CustomSpotlightViewModel<Item> {
		CustomSpotlightViewModel(
			dataSource	 : dataSource,
			sections	 : sections,
			configuration: configuration,
			rowStyle	 : rowStyle
		)
	}
}

// MARK: - Convenience Initializer for FileSpotlight
extension SpotlightBuilder where Item == SpotlightFileItem {
	/// A static factory method to quickly create a spotlight builder pre-configured for searching files.
	///
	/// This helper simplifies the setup for the common use case of creating a file-based search.
	///
	/// - Parameters:
	///   - directory: The root `URL` of the directory to search.
	///   - fileExtensions: An optional array of file extensions to filter by (e.g., ["txt", "md"]).
	///   - onSelect: A closure to be executed when a file item is selected.
	/// - Returns: A `SpotlightBuilder` instance pre-configured with a `FileSystemDataSource`.
	public static func fileSpotlight(
		directory	  : URL,
		fileExtensions: [String]? = nil,
		onSelect	  : @escaping @MainActor (SpotlightFileItem) -> Void
		
	) -> SpotlightBuilder<SpotlightFileItem> {
		let builder    = SpotlightBuilder<SpotlightFileItem>()
		let dataSource = FileSystemDataSource(directory: directory, fileExtensions: fileExtensions)
		
		// Note: The `onSelect` closure is currently not applied here.
		// It would typically be set on the `SpotlightConfiguration` object.
		return builder
			.withDataSource(dataSource)
			.withConfiguration(.init()) // Uses default configuration.
	}
}
