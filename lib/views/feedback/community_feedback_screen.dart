// lib/views/feedback/community_feedback_screen.dart
import 'package:flutter/material.dart';

import '/models/route_model.dart';
import '/models/route_feedback_model.dart';
import '/controllers/route_feedback_controller.dart';

class CommunityFeedbackScreen extends StatefulWidget {
  final RouteModel route;

  const CommunityFeedbackScreen({super.key, required this.route});

  @override
  State<CommunityFeedbackScreen> createState() =>
      _CommunityFeedbackScreenState();
}

class _CommunityFeedbackScreenState extends State<CommunityFeedbackScreen> {
  final _ctrl = RouteFeedbackController();
  late Future<List<RouteFeedback>> _feedbackFuture;

  final _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _submitting = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _feedbackFuture = _ctrl.fetchForRoute(widget.route.routeId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _feedbackFuture = _ctrl.fetchForRoute(widget.route.routeId);
      _status = null;
    });
  }

  Future<void> _submit() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      setState(() => _status = 'Please enter a comment.');
      return;
    }

    setState(() {
      _submitting = true;
      _status = null;
    });

    final err = await _ctrl.addFeedback(
      routeId: widget.route.routeId,
      rating: _selectedRating,
      comment: text,
    );

    if (!mounted) return;

    if (err != null) {
      setState(() {
        _submitting = false;
        _status = err;
      });
      return;
    }

    _commentController.clear();
    setState(() {
      _submitting = false;
      _selectedRating = 5;
      _status = 'Thank you for your feedback!';
      _feedbackFuture = _ctrl.fetchForRoute(widget.route.routeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF9C27B0);
    final r = widget.route;

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback: ${r.name}'),
        backgroundColor: purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F3FF), Color(0xFFFDFBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROUTE HEADER CARD
                Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${(r.distanceM / 1000).toStringAsFixed(2)} km',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'average rating',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (r.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            r.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // COMMUNITY COMMENTS
                const Text(
                  'Community Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                FutureBuilder<List<RouteFeedback>>(
                  future: _feedbackFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Failed to load feedback: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final feedbackList = snapshot.data ?? [];
                    if (feedbackList.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No comments yet. Be the first to share your experience!',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: feedbackList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, index) {
                        final f = feedbackList[index];
                        final name = f.userName?.trim().isNotEmpty == true
                            ? f.userName!
                            : 'Runner';

                        return Card(
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: purple.withValues(
                                        alpha: 0.12,
                                      ),
                                      child: Text(
                                        name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: purple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 14,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${f.rating}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDateTime(f.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  f.comment,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ADD FEEDBACK SECTION
                const Text(
                  'Add Your Feedback',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Text('Rating:', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _selectedRating,
                      items: [1, 2, 3, 4, 5]
                          .map(
                            (v) =>
                                DropdownMenuItem(value: v, child: Text('$v ★')),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedRating = v);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _commentController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Share details about safety, lighting, traffic, etc.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_status != null) ...[
                  Text(
                    _status!,
                    style: TextStyle(
                      color: _status!.startsWith('Failed')
                          ? Colors.red
                          : purple,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _submitting ? 'Submitting...' : 'Submit Feedback',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show local time (EAT on your device) instead of raw UTC
  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal(); // converts from UTC to phone’s timezone
    final d =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final t =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$d $t';
  }
}
