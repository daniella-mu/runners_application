class RoutePhoto {
  final String id;          // uuid
  final int routeId;        // bigint
  final String userId;      // uuid
  final String storagePath;
  final String? caption;
  final String? url;

  RoutePhoto({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.storagePath,
    this.caption,
    this.url,
  });

  factory RoutePhoto.fromMap(Map<String, dynamic> m) {
    final routeIdRaw = m['route_id'];

    return RoutePhoto(
      id: m['id'].toString(), // uuid → String
      routeId: routeIdRaw is int
          ? routeIdRaw
          : int.parse(routeIdRaw.toString()), // handles "9" or 9
      userId: m['user_id'].toString(),
      storagePath: m['storage_path'] as String,
      url: m['url']?.toString(),
      caption: m['caption'] as String?,
    );
  }
}
