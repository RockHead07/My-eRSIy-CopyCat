import 'package:flutter/material.dart';
import 'package:rs_islam_app/features/home/data/models/menu_item_model.dart';

const homeMenuItems = <MenuItemModel>[
  MenuItemModel(
    id: 'promo',
    label: 'Promo Spesial',
    iconAsset: 'assets/icons/menu/promo.png',
    actionType: MenuActionType.comingSoon,
    fallbackIcon: Icons.bolt,
  ),
  MenuItemModel(
    id: 'layanan-unggulan',
    label: 'Layanan Unggulan',
    iconAsset: 'assets/icons/menu/layanan_unggulan.png',
    actionType: MenuActionType.comingSoon,
    fallbackIcon: Icons.star,
  ),
  MenuItemModel(
    id: 'homecare',
    label: 'Homecare',
    iconAsset: 'assets/icons/menu/homecare.png',
    actionType: MenuActionType.webview,
    webUrl: 'https://rsislam-surabaya.com',
    webTitle: 'Homecare RS Islam Surabaya',
    fallbackIcon: Icons.home_filled,
  ),
  MenuItemModel(
    id: 'medical-checkup',
    label: 'Medical Checkup',
    iconAsset: 'assets/icons/menu/medical_checkup.png',
    actionType: MenuActionType.comingSoon,
    fallbackIcon: Icons.assignment,
  ),
  MenuItemModel(
    id: 'vaksinasi',
    label: 'Vaksinasi',
    iconAsset: 'assets/icons/menu/vaksinasi.png',
    actionType: MenuActionType.comingSoon,
    fallbackIcon: Icons.vaccines,
  ),
  MenuItemModel(
    id: 'paket-layanan',
    label: 'Paket Layanan',
    iconAsset: 'assets/icons/menu/paket_layanan.png',
    actionType: MenuActionType.comingSoon,
    fallbackIcon: Icons.family_restroom,
  ),
  MenuItemModel(
    id: 'navigasi-indoor',
    label: 'Navigasi Indoor',
    iconAsset: 'assets/icons/menu/navigasi_indoor.png',
    actionType: MenuActionType.native,
    routeName: 'darsi-navigation',
    fallbackIcon: Icons.explore,
  ),
  MenuItemModel(
    id: 'billing',
    label: 'Billing Rawat Inap',
    iconAsset: 'assets/icons/menu/billing.png',
    actionType: MenuActionType.comingSoon,
    fallbackIcon: Icons.hotel,
  ),
  MenuItemModel(
    id: 'lainnya',
    label: 'Lainnya',
    iconAsset: 'assets/icons/menu/lainnya.png',
    actionType: MenuActionType.comingSoon,
    fallbackIcon: Icons.grid_view,
  ),
];
