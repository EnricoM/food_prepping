import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:parsing/parsing.dart';
import 'package:test/test.dart';

void main() {
  group('DomainRecipeDiscovery.isLikelyRecipeUrl', () {
    test('accepts slug based recipe url', () {
      final uri = Uri.parse(
        'https://www.mycookingjourney.com/veechu-parotta-eggless-veechu-parotta/',
      );
      expect(DomainRecipeDiscovery.isLikelyRecipeUrl(uri), isTrue);
    });

    test('accepts dated wordpress url structure', () {
      final uri = Uri.parse(
        'https://example.com/2024/05/15/lemon-pound-cake/',
      );
      expect(DomainRecipeDiscovery.isLikelyRecipeUrl(uri), isTrue);
    });

    test('rejects listing or utility pages', () {
      final category = Uri.parse('https://example.com/category/recipes/');
      final privacy = Uri.parse('https://example.com/privacy-policy/');
      expect(DomainRecipeDiscovery.isLikelyRecipeUrl(category), isFalse);
      expect(DomainRecipeDiscovery.isLikelyRecipeUrl(privacy), isFalse);
    });
  });

  group('DomainRecipeDiscovery.discoverRecipes', () {
    test('handles sitemap chains that swap between www and apex hosts', () async {
      final responses = <Uri, http.Response>{
        Uri.parse('https://www.example.com/sitemap_index.xml'): http.Response(
          '''
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://example.com/wp-sitemap-posts-post-1.xml</loc>
            </sitemap>
          </sitemapindex>
          ''',
          200,
        ),
        Uri.parse('https://example.com/wp-sitemap-posts-post-1.xml'): http.Response(
          '''
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <url>
              <loc>https://www.example.com/recipes/best-bread-recipe/</loc>
            </url>
          </urlset>
          ''',
          200,
        ),
      };

      final discovery = DomainRecipeDiscovery(
        client: MockClient((request) async {
          return responses[request.url] ?? http.Response('Not Found', 404);
        }),
      );

      final results =
          await discovery.discoverRecipes('https://www.example.com');

      expect(
        results.map((uri) => uri.toString()),
        contains('https://www.example.com/recipes/best-bread-recipe/'),
      );
    });

    test('prioritizes most recently updated URLs', () async {
      final responses = <Uri, http.Response>{
        Uri.parse('https://www.example.com/sitemap_index.xml'): http.Response(
          '''
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <url>
              <loc>https://www.example.com/alpha-beta-gamma/</loc>
              <lastmod>2020-01-01T00:00:00+00:00</lastmod>
            </url>
            <url>
              <loc>https://www.example.com/delta-epsilon-zeta/</loc>
              <lastmod>2024-05-10T12:30:00+00:00</lastmod>
            </url>
            <url>
              <loc>https://www.example.com/mu-nu-xi/</loc>
            </url>
          </urlset>
          ''',
          200,
        ),
        Uri.parse('https://www.example.com/sitemap.xml'):
            http.Response('', 404),
        Uri.parse('https://www.example.com/wp-sitemap.xml'):
            http.Response('', 404),
        Uri.parse('https://www.example.com/sitemap1.xml'):
            http.Response('', 404),
      };

      final discovery = DomainRecipeDiscovery(
        client: MockClient((request) async {
          return responses[request.url] ?? http.Response('Not Found', 404);
        }),
      );

      final results =
          await discovery.discoverRecipes('https://www.example.com', maxUrls: 3);

      expect(
        results.map((uri) => uri.toString()).toList(),
        equals([
          'https://www.example.com/delta-epsilon-zeta/',
          'https://www.example.com/alpha-beta-gamma/',
          'https://www.example.com/mu-nu-xi/',
        ]),
      );
    });
  });
}

