import 'package:flutter/material.dart';
import '/models/route_model.dart';
import '/models/route_photo_model.dart';
import '/controllers/route_photos_controller.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteModel route;

  const RouteDetailScreen({
    super.key,
    required this.route,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final _photosCtrl = RoutePhotosController();
  late Future<List<RoutePhoto>> _photosFuture;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _photosFuture = _photosCtrl.list(widget.route.routeId);
  }

  Future<void> _refreshPhotos() async {
    final items = await _photosCtrl.list(widget.route.routeId);
    if (!mounted) return;
    setState(() => _photosFuture = Future.value(items));
  }

  Future<void> _addPhoto() async {
    if (_uploading) return;
    setState(() => _uploading = true);

    final messenger = ScaffoldMessenger.of(context); // fixes async context warning

    try {
      final ok = await _photosCtrl.pickAndUpload(routeId: widget.route.routeId);
      if (!mounted) return;

      if (ok) {
        await _refreshPhotos();
        messenger.showSnackBar(const SnackBar(content: Text('Photo uploaded')));
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Upload cancelled or failed')));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF9C27B0);
    final r = widget.route;

    return Scaffold(
      appBar: AppBar(
        title: Text(r.name),
        backgroundColor: purple,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPhotos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + stars
              Text(
                r.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              _RatingStars(rating: r.averageRating),

              const SizedBox(height: 16),

              // Stats
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip(icon: Icons.route, label: '${(r.distanceM / 1000).toStringAsFixed(1)} km', color: Colors.teal),
                  _StatChip(icon: Icons.star_rate_rounded, label: r.averageRating.toStringAsFixed(1), color: Colors.orange),
                  _StatChip(icon: Icons.trending_up, label: '${r.popularity}%', color: purple),
                ],
              ),

              const SizedBox(height: 20),

              // Description (optional)
              if (r.description.trim().isNotEmpty) ...[
                Text(r.description, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 20),
              ],

              // Photos
              const Text('Photos from Runners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              FutureBuilder<List<RoutePhoto>>(
                future: _photosFuture,
                builder: (context, snap) {
                  final items = snap.data ?? const <RoutePhoto>[];

                  if (snap.connectionState == ConnectionState.waiting && items.isEmpty) {
                    return const SizedBox(height: 86, child: Center(child: CircularProgressIndicator()));
                  }

                  // Always show "+" first. Then any photos.
                  final count = 1 + items.length;

                  return SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: count,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return _AddPhotoTile(onTap: _uploading ? null : _addPhoto);
                        }

                        final photo = items[i - 1];

                        // ✅ Use DB 'url' if present; else build from storagePath
                        final displayUrl =
                            photo.url ?? _photosCtrl.getPublicUrl(photo.storagePath);

                        return _PhotoThumb.network(displayUrl);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Comments (placeholder)
              const Text('User Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('“Great route with lots of shade and water fountains.” – Alex'),
                      SizedBox(height: 8),
                      Text('“Beautiful views; watch the hill midway!” – Priya'),
                      SizedBox(height: 8),
                      Text('“Crowded on weekends but fun.” – Sam'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Start Run Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('Start run on ${r.name}');
                  },
                  icon: const Icon(Icons.directions_run),
                  label: const Text('Start Run', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====== Reusable bits ======

class _RatingStars extends StatelessWidget {
  final double rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full) return const Icon(Icons.star, color: Colors.amber, size: 18);
        if (i == full && hasHalf) return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
      }),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddPhotoTile({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple, width: 1.2),
        ),
        child: const Center(child: Icon(Icons.add, color: Colors.purple, size: 28)),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final Widget child;
  const _PhotoThumb._(this.child);

  factory _PhotoThumb.network(String url) {
    return _PhotoThumb._(
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          width: 86,
          height: 86,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _gradientBox(const [Color(0xFFD1C4E9), Color(0xFFB39DDB)]),
        ),
      ),
    );
  }

  static Widget _gradientBox(List<Color> colors) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: const Icon(Icons.image, color: Colors.white, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) => child;
}
