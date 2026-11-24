import '../../../core/constants/asset_paths.dart';
import '../models/coloring_page.dart';

abstract final class GalleryData {
  static const String thumbnailFolder =
      AssetPaths.galleryThumbnailsDirectory;

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
      svgPath: '${AssetPaths.coloringImagesDirectory}farmer.svg',
    ),
    item(
      id: 'sakura',
      title: 'Sakura',
      thumbnail: 'sakura.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}sakura.svg',
      isRewarded: true,
    ),
    item(
      id: 'painter',
      title: 'Painter',
      thumbnail: 'painter.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}painter.svg',
    ),
    item(
      id: 'garden',
      title: 'Garden',
      thumbnail: 'garden.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}garden.svg',
    ),
    item(
      id: 'winter',
      title: 'Winter',
      thumbnail: 'winter.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}winter.svg',
    ),
    item(
      id: 'summer',
      title: 'Summer',
      thumbnail: 'summer.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}summer.svg',
    ),
    item(
      id: 'spring',
      title: 'Spring',
      thumbnail: 'spring.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}spring.svg',
    ),
    item(
      id: 'amusument_park',
      title: 'Amusument park',
      thumbnail: 'amusument_park.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}amusument_park.svg',
    ),
    item(
      id: 'chef',
      title: 'Chef',
      thumbnail: 'chef.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}chef.svg',
    ),
    item(
      id: 'halloween',
      title: 'Halloween',
      thumbnail: 'halloween.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}halloween.svg',
    ),
    item(
      id: 'tailor',
      title: 'Tailor',
      thumbnail: 'tailor.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}tailor.svg',
    ),
    item(
      id: 'skater',
      title: 'Skater',
      thumbnail: 'skater.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}skater.svg',
    ),
    item(
      id: 'school',
      title: 'School',
      thumbnail: 'school.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}school.svg',
    ),
    item(
      id: 'newyear_eve',
      title: 'New year eve',
      thumbnail: 'newyear_eve.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}newyear_eve.svg',
    ),
    item(
      id: 'ice_cream',
      title: 'Ice cream',
      thumbnail: 'ice_cream.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}ice_cream.svg',
    ),
    item(
      id: 'gym',
      title: 'Gym',
      thumbnail: 'gym.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}gym.svg',
    ),
    item(
      id: 'flower_shop',
      title: 'Flower shop',
      thumbnail: 'flower_shop.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}flower_shop.svg',
    ),
    item(
      id: 'bed_time',
      title: 'Bed time',
      thumbnail: 'bed_time.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}bed_time.svg',
    ),
    item(
      id: 'astronaut',
      title: 'Astronaut',
      thumbnail: 'astronaut.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}astronaut.svg',
    ),
    item(
      id: 'aquarium',
      title: 'Aquarium',
      thumbnail: 'aquarium.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}aquarium.svg',
    ),
    item(
      id: 'gallery',
      title: 'Gallery',
      thumbnail: 'Gallery.png',
      svgPath: '${AssetPaths.coloringImagesDirectory}Gallery.svg',
    ),
  ];
}
