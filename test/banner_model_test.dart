import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/data/models/banner_model.dart';

void main() {
  test('homeBanners contains 3 new heroCarousel assets', () {
    expect(homeBanners.length, 3);
    expect(homeBanners[0].imageAsset, 'assets/images/heroCarousel1.jpeg');
    expect(homeBanners[1].imageAsset, 'assets/images/heroCarousel2.jpeg');
    expect(homeBanners[2].imageAsset, 'assets/images/heroCarousel3.jpeg');
  });
}
