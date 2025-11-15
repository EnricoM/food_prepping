import 'package:parsing/parsing.dart';
import 'package:test/test.dart';

void main() {
  group('RecipeParser plugin fallbacks', () {
    late RecipeParser parser;

    setUp(() {
      parser = RecipeParser();
    });

    tearDown(() {
      parser.close();
    });

    test('parses WP Recipe Maker markup without JSON-LD', () async {
      const html = '''
      <html>
        <body>
          <div class="wprm-recipe-container">
            <span class="wprm-recipe-name">Sample WP Recipe</span>
            <div class="wprm-recipe-summary">Tasty summary</div>
            <div class="wprm-recipe-image">
              <img data-lazy-src="https://example.com/image.jpg" />
            </div>
            <div class="wprm-recipe-ingredients">
              <ul>
                <li class="wprm-recipe-ingredient">1 cup flour</li>
                <li class="wprm-recipe-ingredient">2 eggs</li>
              </ul>
            </div>
            <div class="wprm-recipe-instructions">
              <div class="wprm-recipe-instruction-text">Mix ingredients</div>
              <div class="wprm-recipe-instruction-text">Bake for 20 minutes</div>
            </div>
            <span class="wprm-recipe-servings">4</span>
            <span class="wprm-recipe-servings-unit">pieces</span>
            <span class="wprm-recipe-prep_time">10</span>
            <span class="wprm-recipe-prep_time-unit">minutes</span>
            <span class="wprm-recipe-cook_time">20</span>
            <span class="wprm-recipe-cook_time-unit">minutes</span>
            <span class="wprm-recipe-total_time">30</span>
            <span class="wprm-recipe-total_time-unit">minutes</span>
            <span class="wprm-recipe-course">Dessert</span>
          </div>
        </body>
      </html>
      ''';

      final result = await parser.parseHtml(
        html,
        sourceUrl: 'https://example.com/wp',
      );

      expect(result.strategy, 'WP Recipe Maker');
      expect(result.recipe.title, 'Sample WP Recipe');
      expect(result.recipe.ingredients, containsAll(['1 cup flour', '2 eggs']));
      expect(result.recipe.instructions.length, 2);
      expect(result.recipe.prepTime, const Duration(minutes: 10));
      expect(result.recipe.cookTime, const Duration(minutes: 20));
      expect(result.recipe.totalTime, const Duration(minutes: 30));
      expect(result.recipe.metadata['plugin'], 'wp-recipe-maker');
      expect(result.recipe.imageUrl, 'https://example.com/image.jpg');
    });
  });
}

