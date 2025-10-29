//
//  Mock.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI
// MARK: - Preview con Mock Data

#Preview("Spotlight with Mock Data") {
	@Previewable @StateObject var viewModel = SpotlightViewModel<SpotlightFileItem>.fileSearch(
		directory: URL(fileURLWithPath: "/Users/eliorodr2104/Downloads"),
		fileExtensions: ["pdf"],
		configuration: .init(
			debounceInterval: 150,
			maxHeight: 400,
			cornerRadius: 24,
			showDividers: true
		)
	)
	
	ZStack {
		// Background gradient
		LinearGradient(
			colors: [
				Color(red: 0.1, green: 0.1, blue: 0.2),
				Color(red: 0.2, green: 0.1, blue: 0.3)
			],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.ignoresSafeArea()
		
		VStack(spacing: 20) {
			Text("SpotlightKit Demo")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundColor(.white)
			
			Text("Try searching: 'View', 'Swift', 'README'")
				.font(.subheadline)
				.foregroundColor(.white.opacity(0.7))
			
			SpotlightView(viewModel: viewModel, width: 600)
				.padding(.top, 20)
			
			Spacer()
			
			// Info panel
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					Image(systemName: "keyboard")
						.foregroundColor(.white.opacity(0.7))
					Text("Keyboard Shortcuts:")
						.font(.headline)
						.foregroundColor(.white)
				}
				
				Group {
					shortcutRow(icon: "arrow.up", text: "Navigate Up")
					shortcutRow(icon: "arrow.down", text: "Navigate Down")
					shortcutRow(icon: "return", text: "Select Item")
					shortcutRow(icon: "escape", text: "Clear/Reset")
				}
			}
			.padding()
			.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
			.padding(.horizontal, 40)
			.padding(.bottom, 40)
		}
		.padding(.top, 60)
	}
	.frame(width: 900, height: 700)
}

private func shortcutRow(icon: String, text: String) -> some View {
	HStack(spacing: 12) {
		Image(systemName: icon)
			.frame(width: 20)
			.foregroundColor(.white.opacity(0.6))
		Text(text)
			.font(.subheadline)
			.foregroundColor(.white.opacity(0.8))
	}
}

// MARK: - Preview Multi-Section

#Preview("Multi-Section Spotlight") {
	@Previewable @StateObject var viewModel = {
		let dataSource = FileSystemDataSource(
			directory: URL(fileURLWithPath: "/Users/eliorodr2104/Downloads"),
			fileExtensions: ["pdf"]
		)
		let vm = SpotlightViewModel<SpotlightFileItem>(
			dataSource: dataSource,
			configuration: .init(
				cornerRadius: 20
			)
		)
		
		// Recent files section
		vm.addSection(
			SpotlightSection(
				id: "recent",
				title: "Recent Files",
				icon: "clock",
				view	: { Text("Test 0") },
				onSelect: { file in
					print("Selected recent: \(file.displayName)")
				}
			)
		)
		
		// Favorites section
		vm.addSection(
			SpotlightSection(
				id: "favorites",
				title: "Favorites",
				icon: "star.fill",
				view	: { Text("Test 1") },
				onSelect: { file in
					print("Selected favorite: \(file.displayName)")
				}
			)
		)
		
		return vm
	}()
	
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
			
			MultiSectionSpotlightView(viewModel: viewModel, width: 650)
			
			Spacer()
		}
		.padding(.top, 80)
	}
	.frame(width: 900, height: 700)
}

// MARK: - Preview Compact Style

#Preview("Compact Style") {
	@Previewable @StateObject var viewModel = {
		let dataSource = FileSystemDataSource(
			directory: URL(fileURLWithPath: "/Users/eliorodr2104/Downloads"),
			fileExtensions: ["pdf"]
		)
		
		let vm = SpotlightViewModel<SpotlightFileItem>(
			dataSource: dataSource,
			configuration: .init(
				debounceInterval: 100,
				maxHeight: 250,
				cornerRadius: 12
			),
			rowStyle: .init(
				backgroundColor: { selected in
					selected ? Color.purple.opacity(0.2) : Color.clear
				},
				cornerRadius: 6,
				padding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
				spacing: 10,
				iconSize: 22
			)
		)
		
		return vm
	}()
	
	ZStack {
		LinearGradient(
			colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.ignoresSafeArea()
		
		VStack {
			Text("Compact Spotlight")
				.font(.title2)
				.fontWeight(.semibold)
			
			SpotlightView(viewModel: viewModel, width: 450)
				.padding(.top, 20)
			
			Spacer()
		}
		.padding(.top, 100)
	}
	.frame(width: 600, height: 500)
}
