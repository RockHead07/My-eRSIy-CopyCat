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
    imageAsset: 'assets/images/banner_hospital.png',
    title: 'Kunjungi kami sesuai jam yang ditetapkan',
    morningHours: 'PAGI 10.00 - 12.00 WIB',
    afternoonHours: 'SORE 16.00 - 18.00 WIB',
    fridayNote: "Kecuali Jum'at pagi 09.00 - 11.00 WIB",
  ),
  BannerModel(
    imageAsset: 'assets/images/banner_hospital.png',
    title: 'Layanan IGD 24 Jam siap melayani Anda',
    morningHours: 'IGD BUKA 24 JAM',
    afternoonHours: 'HUBUNGI CALL CENTER',
    fridayNote: 'Informasi lengkap di website resmi',
  ),
  BannerModel(
    imageAsset: 'assets/images/banner_hospital.png',
    title: 'Medical Checkup & Vaksinasi tersedia',
    morningHours: 'DAFTAR ONLINE',
    afternoonHours: 'KONSULTASI DOKTER',
    fridayNote: 'Promo spesial bulan ini',
  ),
];
