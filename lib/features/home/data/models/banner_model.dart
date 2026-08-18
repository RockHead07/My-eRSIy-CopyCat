class BannerModel {
  const BannerModel({
    required this.imageAsset,
    required this.title,
    required this.morningHours,
    required this.afternoonHours,
    required this.fridayNote,
  });

  final String imageAsset;
  final String title;
  final String morningHours;
  final String afternoonHours;
  final String fridayNote;
}

const homeBanners = <BannerModel>[
  BannerModel(
    imageAsset: 'assets/images/heroCarousel1.jpeg',
    title: 'Kunjungi kami sesuai jam yang ditetapkan',
    morningHours: 'PAGI 10.00 - 12.00 WIB',
    afternoonHours: 'SORE 16.00 - 18.00 WIB',
    fridayNote: "Kecuali Jum'at pagi 09.00 - 11.00 WIB",
  ),
  BannerModel(
    imageAsset: 'assets/images/heroCarousel2.jpeg',
    title: 'Melayani BPJS dan Non-BPJS',
    morningHours: 'INFORMASI LEBIH LANJUT',
    afternoonHours: 'CHAT WA: 0814-0090-6200',
    fridayNote: 'Layanan Sepenuh Hati',
  ),
  BannerModel(
    imageAsset: 'assets/images/heroCarousel3.jpeg',
    title: 'Nomor RSI Baru, Akses Informasi Lebih Mudah',
    morningHours: 'LAYANAN INFORMASI',
    afternoonHours: 'CHAT WA: 0821-3322-2247',
    fridayNote: 'Hubungi via WhatsApp',
  ),
];
