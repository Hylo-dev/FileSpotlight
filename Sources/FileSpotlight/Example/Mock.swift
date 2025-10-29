//
//  Mock.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

// This file contains SwiftUI Previews for demonstrating different configurations
// and styles of the spotlight components.

// MARK: - Multi-Section Spotlight Preview

#Preview("Multi-Section Spotlight") {
	// 1. Initialize the ViewModel for the multi-section spotlight.
	@Previewable @StateObject var viewModelSpotlight = MultiSectionSpotlightViewModel<SpotlightFileItem>(
		
		// 2. Set up the primary data source to search for PDF files in the user's Downloads directory.
		dataSource: FileSystemDataSource(
			directory: URL(fileURLWithPath: "/Users/eliorodr2104/Downloads"), // Note: This path is hardcoded for the preview.
			fileExtensions: ["pdf"]
		),
		
		// 3. Define custom sections, each with a unique ID, title, icon, and a custom view.
		sections: [
			SpotlightSection(
				id	    : "recent",
				title   : "Recent Files",
				icon    : "clock",
				view    : { Text("Custom view for 'Recent Files'") }, // The view displayed when this section is active.
				onSelect: { file in
					print("Selected recent: \(file.displayName)")
				}
			),
			
			SpotlightSection(
				id		: "favorites",
				title	: "Favorites",
				icon	: "star.fill",
				view	: { Text("Custom view for 'Favorites'") }, // The view displayed when this section is active.
				onSelect: { file in
					print("Selected favorite: \(file.displayName)")
				}
			)
		]
	)
	
	// 4. Set up the preview's hosting environment.
	ZStack {
		Color.black
			.ignoresSafeArea()
		
		VStack(spacing: 30) {
			Text("Multi-Section Spotlight")
				.font(.largeTitle)
				.fontWeight(.bold)
			
			Text("Browse by sections or search across all items")
				.font(.subheadline)
				.foregroundColor(.secondary)
			
			// 5. Instantiate the main spotlight view with its view model.
			MultiSectionSpotlightView(viewModel: viewModelSpotlight, width: 650)
//				.sectionButtonSize(55)
//				.clipShape(.rect(cornerRadius: 20))
			
			Spacer()
		}
		.padding(.top, 80)
	}
	.frame(width: 900, height: 700)
}

// MARK: - Compact Style Spotlight Preview

#Preview("Compact Style") {
	// 1. Use @Previewable and @StateObject to create and manage the view model's state within the preview.
	@Previewable @StateObject var viewModel = {
		let dataSource = FileSystemDataSource(
			directory: URL(fileURLWithPath: "/Users/eliorodr2104/Downloads"), // Note: This path is hardcoded for the preview.
			fileExtensions: ["pdf"]
		)
		
		// 2. Initialize a specific view model for file searching.
		let vm = FileSearchSpotlightViewModel<SpotlightFileItem>(
			dataSource: dataSource,
			
			// 3. Provide a custom configuration to override default behaviors.
			configuration: .init(
				debounceInterval: 100, // Shorter delay before searching.
				maxHeight		: 250         // Smaller maximum height for the results list.
			),
			
			// 4. Provide a custom row style to change the appearance of each result.
			rowStyle: .init(
				backgroundColor: { selected in
					selected ? Color.purple.opacity(0.2) : Color.clear // Custom selection color.
				},
				cornerRadius: 6,
				padding: EdgeInsets(
					top		: 8,
					leading : 8,
					bottom	: 8,
					trailing: 8
				),
				spacing : 10,
				iconSize: 22
			)
		)
		
		return vm
	}()
	
	// 5. Set up the preview's hosting environment with a decorative gradient.
	ZStack {
		LinearGradient(
			colors	  : [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
			startPoint: .topLeading,
			endPoint  : .bottomTrailing

		)
		.ignoresSafeArea()
		
		VStack {
			Text("Compact Spotlight")
				.font(.title2)
				.fontWeight(.semibold)
			
			// 6. Instantiate the spotlight view with a smaller width for a compact look.
			FileSearchSpotlightView(
				viewModel: viewModel,
				width	 : 450
			)
			.padding(.top, 20)
			.clipShape(.rect(cornerRadius: 12))
			
			Spacer()
		}
		.padding(.top, 100)
	}
	.frame(width: 600, height: 500)
}
