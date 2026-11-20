
import '../models/coloring_page.dart';

abstract final class GalleryData {
  static const String thumbnailFolder =
      'assets/images/gallery/thumbnails/';

  static ColoringPage item({
    required String id,
    required String title,
    required String thumbnail,
    required String svgPath,
  }) {
    return ColoringPage(
      id: id,
      title: title,
      thumbnailPath: '$thumbnailFolder$thumbnail',
      imagePath: svgPath,
    );
  }

  static final List<ColoringPage> pages = [
    item(
      id: 'farmer',
      title: 'Farmer',
      thumbnail: 'farmer.png',
      svgPath: 'assets/images/coloring/01.svg',
    ),
    item(
      id: 'sakura',
      title: 'Sakura',
      thumbnail: 'sakura.png',
      svgPath: 'assets/images/coloring/02.svg',
    ),
    item(
      id: 'painter',
      title: 'Painter',
      thumbnail: 'painter.png',
      svgPath: 'assets/images/coloring/a.svg',
    ),
    item(
      id: 'garden',
      title: 'Garden',
      thumbnail: 'garden.png',
      svgPath: 'assets/images/coloring/c.svg',
    ),
    item(
      id: 'winter',
      title: 'Winter',
      thumbnail: 'winter.png',
      svgPath: 'assets/images/coloring/i.svg',
    ),
    item(
      id: 'summer',
      title: 'Summer',
      thumbnail: 'summer.png',
      svgPath: 'assets/images/coloring/s.svg',
    ),
    item(
      id: 'spring',
      title: 'Spring',
      thumbnail: 'spring.png',
      svgPath: 'assets/images/coloring/spring.png',
    ),
    item(
      id: 'amusument_park',
      title: 'Amusument park',
      thumbnail: 'amusument_park.png',
      svgPath: 'assets/images/coloring/amusument_park.png',
    ),

    item(
      id: 'chef',
      title: 'Chef',
      thumbnail: 'chef.png',
      svgPath: 'assets/images/coloring/chef.png',
    ),

    item(
      id: 'halloween',
      title: 'Halloween',
      thumbnail: 'halloween.png',
      svgPath: 'assets/images/coloring/halloween.png',
    ),

    item(
      id: 'tailor',
      title: 'Tailor',
      thumbnail: 'tailor.png',
      svgPath: 'assets/images/coloring/tailor.png',
    ),
    item(
      id: 'skater',
      title: 'Skater',
      thumbnail: 'skater.png',
      svgPath: 'assets/images/coloring/skater.png',
    ),
    item(
      id: 'school',
      title: 'School',
      thumbnail: 'school.png',
      svgPath: 'assets/images/coloring/school.png',
    ),
    item(
      id: 'newyear_eve',
      title: 'New year eve',
      thumbnail: 'newyear_eve.png',
      svgPath: 'assets/images/coloring/newyear_eve.png',
    ),
    item(
      id: 'ice_cream',
      title: 'Ice cream',
      thumbnail: 'ice_cream.png',
      svgPath: 'assets/images/coloring/ice_cream.png',
    ),
    item(
      id: 'gym',
      title: 'Gym',
      thumbnail: 'gym.png',
      svgPath: 'assets/images/coloring/gym.png',
    ),

    item(
      id: 'flower_shop',
      title: 'Flower shop',
      thumbnail: 'flower_shop.png',
      svgPath: 'assets/images/coloring/flower_shop.png',
    ),
    item(
      id: 'bed_time',
      title: 'Bed time',
      thumbnail: 'bed_time.png',
      svgPath: 'assets/images/coloring/bed_time.png',
    ),
    item(
      id: 'astronaut',
      title: 'Astronaut',
      thumbnail: 'astronaut.png',
      svgPath: 'assets/images/coloring/astronaut.png',
    ),
    item(
      id: 'aquarium',
      title: 'Aquarium',
      thumbnail: 'aquarium.png',
      svgPath: 'assets/images/coloring/aquarium.png',
    ),

    // Diğer 17 çizimi buraya ekle.
  ];
}
