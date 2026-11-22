
import '../models/coloring_page.dart';

abstract final class GalleryData {
  static const String thumbnailFolder =
      'assets/images/gallery/thumbnails/';

  static ColoringPage item({
    required String id,
    required String title,
    required String thumbnail,
    required String svgPath,
    bool isRewarded = false,
  }) {
    return ColoringPage(
      id: id,
      title: title,
      thumbnailPath: '$thumbnailFolder$thumbnail',
      imagePath: svgPath,
      isRewarded: isRewarded,
    );
  }


  static final List<ColoringPage> pages = [
    item(
      id: 'farmer',
      title: 'Farmer',
      thumbnail: 'farmer.png',
      svgPath: 'assets/images/coloring/farmer.svg',
    ),
    item(
      id: 'sakura',
      title: 'Sakura',
      thumbnail: 'sakura.png',
      svgPath: 'assets/images/coloring/sakura.svg',
      isRewarded: true,
    ),
    item(
      id: 'painter',
      title: 'Painter',
      thumbnail: 'painter.png',
      svgPath: 'assets/images/coloring/painter.svg',
    ),
    item(
      id: 'garden',
      title: 'Garden',
      thumbnail: 'garden.png',
      svgPath: 'assets/images/coloring/garden.svg',
    ),
    item(
      id: 'winter',
      title: 'Winter',
      thumbnail: 'winter.png',
      svgPath: 'assets/images/coloring/winter.svg',
    ),
    item(
      id: 'summer',
      title: 'Summer',
      thumbnail: 'summer.png',
      svgPath: 'assets/images/coloring/summer.svg',
    ),
    item(
      id: 'spring',
      title: 'Spring',
      thumbnail: 'spring.png',
      svgPath: 'assets/images/coloring/spring.svg',
    ),
    item(
      id: 'amusument_park',
      title: 'Amusument park',
      thumbnail: 'amusument_park.png',
      svgPath: 'assets/images/coloring/amusument_park.svg',
    ),

    item(
      id: 'chef',
      title: 'Chef',
      thumbnail: 'chef.png',
      svgPath: 'assets/images/coloring/chef.svg',
    ),

    item(
      id: 'halloween',
      title: 'Halloween',
      thumbnail: 'halloween.png',
      svgPath: 'assets/images/coloring/halloween.svg',
    ),

    item(
      id: 'tailor',
      title: 'Tailor',
      thumbnail: 'tailor.png',
      svgPath: 'assets/images/coloring/tailor.svg',
    ),
    item(
      id: 'skater',
      title: 'Skater',
      thumbnail: 'skater.png',
      svgPath: 'assets/images/coloring/skater.svg',
    ),
    item(
      id: 'school',
      title: 'School',
      thumbnail: 'school.png',
      svgPath: 'assets/images/coloring/school.svg',
    ),
    item(
      id: 'newyear_eve',
      title: 'New year eve',
      thumbnail: 'newyear_eve.png',
      svgPath: 'assets/images/coloring/newyear_eve.svg',
    ),
    item(
      id: 'ice_cream',
      title: 'Ice cream',
      thumbnail: 'ice_cream.png',
      svgPath: 'assets/images/coloring/ice_cream.svg',
    ),
    item(
      id: 'gym',
      title: 'Gym',
      thumbnail: 'gym.png',
      svgPath: 'assets/images/coloring/gym.svg',
    ),

    item(
      id: 'flower_shop',
      title: 'Flower shop',
      thumbnail: 'flower_shop.png',
      svgPath: 'assets/images/coloring/flower_shop.svg',
    ),
    item(
      id: 'bed_time',
      title: 'Bed time',
      thumbnail: 'bed_time.png',
      svgPath: 'assets/images/coloring/bed_time.svg',
    ),
    item(
      id: 'astronaut',
      title: 'Astronaut',
      thumbnail: 'astronaut.png',
      svgPath: 'assets/images/coloring/astronaut.svg',
    ),
    item(
      id: 'aquarium',
      title: 'Aquarium',
      thumbnail: 'aquarium.png',
      svgPath: 'assets/images/coloring/aquarium.svg',
    ),
  ];
}
