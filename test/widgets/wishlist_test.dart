import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:balanza/models/wishlist_item.dart';
import 'package:balanza/features/wishlist/providers/wishlist_provider.dart';
import 'package:balanza/features/wishlist/presentation/wishlist_view.dart';

class MockWishlistNotifier extends WishlistNotifier {
  @override
  List<WishlistItem> build() {
    return [
      WishlistItem(
        id: 'w-1',
        title: 'Pre-purchase Item',
        amount: 150.0,
        createdAt: DateTime.now(),
        coolingOffDays: 30,
        status: 'cooling_off',
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        wishlistProvider.overrideWith(() => MockWishlistNotifier()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WishlistView(),
      ),
    );
  }

  group('WishlistView Widget Tests', () {
    testWidgets('Renders Wishlist title, summary, and item list', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Cooling-Off Wishlist'), findsOneWidget);
      expect(find.textContaining('150.00 RON'), findsWidgets);
      expect(find.text("I Don't Need It (Saved!)"), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
    });
  });
}
