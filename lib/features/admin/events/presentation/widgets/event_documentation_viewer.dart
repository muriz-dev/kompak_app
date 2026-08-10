import 'dart:ui';

import 'package:flutter/material.dart';

import '../../domain/entities/admin_event_overview.dart';

class EventDocumentationViewer extends StatefulWidget {
  const EventDocumentationViewer({
    required this.documentation,
    this.initialIndex = 0,
    super.key,
  });

  final List<AdminEventDocumentation> documentation;
  final int initialIndex;

  @override
  State<EventDocumentationViewer> createState() =>
      _EventDocumentationViewerState();
}

class _EventDocumentationViewerState extends State<EventDocumentationViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Material(
        color: const Color(0xB324282E),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 342),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.08,
                          child: PageView.builder(
                            key: const ValueKey('documentation-page-view'),
                            controller: _controller,
                            itemCount: widget.documentation.length,
                            onPageChanged: (value) =>
                                setState(() => _index = value),
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _NetworkPhoto(
                                url: widget.documentation[index].url,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AuthorRow(documentation: widget.documentation[_index]),
                        if (widget.documentation[_index].description
                            case final description?
                            when description.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              description,
                              style: const TextStyle(
                                color: Color(0xFF55585C),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                        if (widget.documentation.length > 1) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (
                                var index = 0;
                                index < widget.documentation.length;
                                index++
                              )
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: index == _index ? 18 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index == _index
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFD6D9DE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: IconButton.filled(
                  key: const ValueKey('close-documentation-viewer'),
                  tooltip: 'Tutup dokumentasi',
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xCC24282E),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.documentation});

  final AdminEventDocumentation documentation;

  @override
  Widget build(BuildContext context) {
    final initials = documentation.contributorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFE7EEFF),
          foregroundColor: const Color(0xFF2563EB),
          child: Text(
            initials.isEmpty ? 'W' : initials,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                documentation.contributorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2F3236),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                documentation.contributorLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF8A8C90), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NetworkPhoto extends StatelessWidget {
  const _NetworkPhoto({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFF1F3F5),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF8A8C90),
            size: 38,
          ),
        ),
      ),
    );
  }
}
