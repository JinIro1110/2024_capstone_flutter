import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/models/MallItem.dart';
import 'package:flutter_application_1/utils/constants.dart';

class MallItemCard extends StatelessWidget {
  final MallItem item;
  final VoidCallback? onLikePressed;
  final VoidCallback? onBuyPressed;

  const MallItemCard({
    Key? key, 
    required this.item,
    this.onLikePressed,
    this.onBuyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedPrice = '${int.parse(item.price).toLocaleString()}원';

    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(224, 165, 147, 224),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error, color: Colors.red, size: 20),
                        ),
                      ),
                    ),
                  ),
                  if (onLikePressed != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildLikeButton(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.brand,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      color: Color.fromARGB(224, 165, 147, 224),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (onBuyPressed != null)
                    _buildBuyButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.favorite_border,
          color: Colors.white,
          size: 16,
        ),
        padding: EdgeInsets.zero,
        onPressed: onLikePressed,
      ),
    );
  }

  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: onBuyPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          '구매하기',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

extension NumberFormat on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}