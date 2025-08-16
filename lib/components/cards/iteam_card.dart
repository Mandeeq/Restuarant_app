import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../utils/image_utils.dart';
import '../small_dot.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.foodType,
    required this.price,
    required this.priceRange,
    required this.press,
  });

  final String? title, description, image, foodType, priceRange;
  final double? price;
  final VoidCallback press;

  Widget buildImage(String? imageUrl) {
    final fallbackUrl = ImageUtils.getDefaultImageUrl();
    final fullImageUrl = ImageUtils.getImageUrl(imageUrl);

    return Image.network(
      fullImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(fallbackUrl, fit: BoxFit.cover);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: titleColor.withOpacity(0.64),
          fontWeight: FontWeight.normal,
        );
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              // Fixed size image container to prevent overflow
              Container(
                width: 110,
                height: 110,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: buildImage(image),
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 16), // Reduced font size
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12, // Smaller font to fit better
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            priceRange!,
                            style: textStyle.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: defaultPadding / 2),
                          child: SmallDot(),
                        ),
                        Flexible(
                          child: Text(
                            foodType!,
                            style: textStyle.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "USD$price",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                color: primaryColor,
                                fontSize: 12, // Smaller font size
                              ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
