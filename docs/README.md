# Recipe Parser Flutter App

A Flutter application that fetches and extracts structured recipe data from public web pages. Paste a recipe URL and the app will attempt to retrieve ingredients, instructions, imagery, timing metadata, and other context by combining JSON-LD, schema.org microdata, and heuristic DOM parsing.

## Features

- Paste any absolute recipe URL and parse it on device.
- Displays title, description, author, servings, timings, image, ingredients, and step-by-step instructions.
- Supports structured data (JSON-LD and schema.org microdata) with graceful fallbacks for common layouts.
- Provides parsing diagnostics so you can see which strategy succeeded.

## Getting Started

1. Ensure you have Flutter installed (3.9.0 or later) and set up for your platform.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on a simulator or physical device:
   ```bash
   flutter run
   ```
4. Paste a recipe URL (e.g. a blog or publisher site) into the text field and tap **Parse Recipe**.

## Project Structure

- `lib/models/recipe.dart` – immutable model describing parsed recipe data.
- `lib/services/recipe_parser.dart` – networking + HTML parsing logic with multiple extraction strategies.
- `lib/main.dart` – Flutter UI for entering URLs, displaying results, and debugging parsing notes.

## Notes & Limitations

- The parser expects publicly accessible pages. Sites requiring authentication or blocked by paywalls may fail.
- Some recipe layouts embed data in custom widgets or JavaScript that requires bespoke handling; these renderings fall back to heuristic parsing when possible.
- Network requests include a generic user agent. Modify `RecipeParser.parseUrl` if you need custom headers or proxying.

## Contributing

Issues and pull requests are welcome. Feel free to extend the parsing heuristics, add caching, or enhance the presentation layer.
# food_prepping
