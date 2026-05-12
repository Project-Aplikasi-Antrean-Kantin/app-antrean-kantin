import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/organisms/menu_tile/widgets/menu_tile_add_button.dart';
import 'package:testgetdata/presentation/widgets/organisms/menu_tile/widgets/menu_tile_badge.dart';
import 'package:testgetdata/presentation/widgets/organisms/menu_tile/widgets/menu_tile_counter.dart';

class MenuTileImage extends StatelessWidget {
  final TenantFoods food;
  final TenantModel tenant;
  final int cartItemCount;
  final bool isOwner;

  const MenuTileImage({
    Key? key,
    required this.food,
    required this.tenant,
    required this.cartItemCount,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();

    return food.isReady == 1
        ? Stack(children: [
            image,
            Positioned(
              bottom: isOwner && cartItemCount > 0 ? 0 : 4,
              right: isOwner && cartItemCount > 0 ? 0 : 4,
              child: _buildOverlay(context),
            ),
          ])
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: Stack(children: [
              image,
              if (!isOwner)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: MenuTileBadge(count: cartItemCount),
                ),
            ]),
          );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: ImageByUrl(
        key: Key(food.gambar.toString()),
        url: food.gambar.toString(),
        width: 144,
        height: 144,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    if (cartItemCount > 0) {
      return isOwner
          ? MenuTileCounter(food: food, tenant: tenant)
          : MenuTileBadge(count: cartItemCount);
    }
    return MenuTileAddButton(food: food, tenant: tenant, isOwner: isOwner);
  }
}
