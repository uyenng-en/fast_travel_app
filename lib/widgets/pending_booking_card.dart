import 'package:flutter/material.dart';

class PendingBookingCard extends StatelessWidget {
  final String imageUrl; // asset path or network URL
  final String title;
  final String checkInLine; // e.g. "Ngày nhận phòng: T3, 25 thg 2"
  final String subInfo; // e.g. "1 đêm, 2 người lớn"
  final VoidCallback? onTap;
  final double borderRadius;
  final double height;

  const PendingBookingCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.checkInLine,
    required this.subInfo,
    this.onTap,
    this.borderRadius = 16,
    this.height = 180,
  }) : super(key: key);

  Widget _buildImage(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');
    final image = isNetwork
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Image.asset(imageUrl, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            // dark gradient at top-left for title readability
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.45),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Title
            Positioned(
              left: 12,
              top: 12,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF3FF), // soft blue
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            checkInLine,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B72C1), // darker blue for title
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subInfo,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the whole card with InkWell if onTap provided
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImage(context),
          const SizedBox(height: 12),
          // padding around info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildInfoBox(context),
          ),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: card);
  }
}
