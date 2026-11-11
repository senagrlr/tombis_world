import '../models/coloring_category.dart';
import '../models/coloring_page.dart';

abstract final class GalleryData {
  static const categories = <ColoringCategory>[
    ColoringCategory(id: 'halloween', name: 'Halloween'),
    ColoringCategory(id: 'summer', name: 'Summer'),
    ColoringCategory(id: 'love', name: 'Love'),
    ColoringCategory(id: 'friends', name: 'Friends'),
  ];

  static const pages = <ColoringPage>[
    ColoringPage(
      id: 'halloween_01',
      categoryId: 'halloween',
      imagePath: 'assets/images/coloring/halloween/01.svg',
    ),
    ColoringPage(
      id: 'summer_01',
      categoryId: 'summer',
      imagePath: 'assets/images/coloring/summer/01.svg',
    ),
    ColoringPage(
      id: 'summer_02',
      categoryId: 'summer',
      imagePath: 'assets/images/coloring/summer/02.svg',
    ),
    ColoringPage(
      id: 'love_01',
      categoryId: 'love',
      imagePath: 'assets/images/coloring/love/01.svg',
    ),
    ColoringPage(
      id: 'friends_01',
      categoryId: 'friends',
      imagePath: 'assets/images/coloring/friends/01.svg',
    ),
  ];
}
