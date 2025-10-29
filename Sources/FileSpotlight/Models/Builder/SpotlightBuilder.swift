//
//  SpotlightBuilder.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// Builder per configurare lo spotlight facilmente
@MainActor
public class SpotlightBuilder<Item: SpotlightItem> {
	private var dataSource: (any SpotlightDataSource)?
	private var sections: [SpotlightSection<Item>] = []
	private var configuration = SpotlightConfiguration.default
	private var rowStyle = SpotlightRowStyle.default
	
	public init() {}
	
	public func withDataSource<DS: SpotlightDataSource>(_ dataSource: DS) -> Self where DS.Item == Item {
		self.dataSource = dataSource
		return self
	}
	
	public func withSection(_ section: SpotlightSection<Item>) -> Self {
		sections.append(section)
		return self
	}
	
	public func withConfiguration(_ configuration: SpotlightConfiguration) -> Self {
		self.configuration = configuration
		return self
	}
	
	public func withRowStyle(_ style: SpotlightRowStyle) -> Self {
		self.rowStyle = style
		return self
	}
	
	public func build() -> SpotlightViewModel<Item> {
		SpotlightViewModel(
			dataSource: dataSource,
			sections: sections,
			configuration: configuration,
			rowStyle: rowStyle
		)
	}
}

extension SpotlightBuilder where Item == SpotlightFileItem {
	/// Helper per creare rapidamente uno spotlight per file
	public static func fileSpotlight(
		directory: URL,
		fileExtensions: [String]? = nil,
		onSelect: @escaping @MainActor (SpotlightFileItem) -> Void
		
	) -> SpotlightBuilder<SpotlightFileItem> {
		let builder = SpotlightBuilder<SpotlightFileItem>()
		let dataSource = FileSystemDataSource(directory: directory, fileExtensions: fileExtensions)
		
		return builder
			.withDataSource(dataSource)
			.withConfiguration(.init())
	}
}
