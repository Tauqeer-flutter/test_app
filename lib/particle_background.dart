import 'dart:math';

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════
//  PARTICLE DATA MODEL
// ═══════════════════════════════════════════════════════
class _ParticleData {
  final double leftFraction;
  final double topFraction;
  final double size;
  final Color color;
  final double glowRadius;
  final Duration duration;
  final Duration delay;

  const _ParticleData({
    required this.leftFraction,
    required this.topFraction,
    required this.size,
    required this.color,
    required this.glowRadius,
    required this.duration,
    required this.delay,
  });
}

// ═══════════════════════════════════════════════════════
//  STATIC PARTICLE DEFINITIONS
// ═══════════════════════════════════════════════════════
final List<_ParticleData> _staticParticles = () {
  const Color blue = Color(0x993B82F6);
  const Color cyan = Color(0x9906B6D4);
  const Color purple = Color(0x808B5CF6);

  const cyanSet = {3, 7, 13, 18, 22, 27};
  const purpleSet = {5, 11, 16, 24, 29};

  const raw = [
    [5, 10, 18, 0.0, 8.0],
    [15, 80, 22, 1.0, 6.0],
    [25, 30, 16, 2.0, 10.0],
    [35, 60, 20, 0.5, 6.0],
    [45, 15, 19, 3.0, 7.0],
    [55, 85, 17, 1.5, 6.0],
    [65, 40, 21, 2.5, 9.0],
    [75, 70, 23, 0.8, 6.0],
    [85, 20, 18, 1.8, 8.0],
    [92, 55, 20, 2.2, 6.0],
    [8, 45, 16, 3.5, 5.0],
    [30, 90, 24, 0.3, 6.0],
    [50, 5, 19, 1.2, 11.0],
    [70, 95, 17, 2.8, 6.0],
    [88, 35, 21, 0.7, 6.0],
    [3, 50, 19, 0.2, 7.0],
    [12, 25, 21, 1.3, 6.0],
    [20, 70, 17, 2.1, 9.0],
    [40, 40, 23, 0.6, 6.0],
    [60, 20, 18, 1.7, 8.0],
    [78, 50, 20, 2.4, 6.0],
    [95, 75, 16, 0.9, 10.0],
    [82, 88, 22, 3.2, 6.0],
    [48, 92, 19, 1.1, 6.0],
    [22, 8, 24, 2.7, 6.0],
    [58, 65, 17, 0.4, 8.0],
    [72, 12, 21, 1.9, 6.0],
    [38, 78, 18, 2.9, 7.0],
    [7, 65, 20, 0.1, 6.0],
    [90, 42, 23, 3.8, 9.0],
  ];

  return List<_ParticleData>.generate(raw.length, (i) {
    final idx = i + 1;
    Color c = blue;
    double glow = 10;
    if (cyanSet.contains(idx)) {
      c = cyan;
      glow = 12;
    } else if (purpleSet.contains(idx)) {
      c = purple;
      glow = 10;
    }
    final r = raw[i];
    return _ParticleData(
      leftFraction: (r[0]).toDouble() / 100,
      topFraction: (r[1]).toDouble() / 100,
      duration: Duration(seconds: (r[2]).toInt()),
      delay: Duration(milliseconds: ((r[3]) * 1000).toInt()),
      size: (r[4]).toDouble(),
      color: c,
      glowRadius: glow,
    );
  });
}();

// ═══════════════════════════════════════════════════════
//  ANIMATED DOT PARTICLE
// ═══════════════════════════════════════════════════════
class _AnimatedParticle extends StatefulWidget {
  final _ParticleData data;
  const _AnimatedParticle({required this.data});
  @override
  State<_AnimatedParticle> createState() => _AnimatedParticleState();
}

class _AnimatedParticleState extends State<_AnimatedParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _dx = [0.0, 15.0, -10.0, 20.0, 0.0];
  static const _dy = [0.0, -30.0, -15.0, -40.0, 0.0];
  static const _sc = [1.0, 1.2, 0.9, 1.1, 1.0];
  static const _op = [0.6, 1.0, 0.8, 0.9, 0.6];

  late final Animation<double> _dxA, _dyA, _scA, _opA;

  TweenSequence<double> _seq(List<double> v) => TweenSequence([
    for (int i = 0; i < v.length - 1; i++)
      TweenSequenceItem(
        tween: Tween(begin: v[i], end: v[i + 1]),
        weight: 1,
      ),
  ]);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.data.duration)
      ..addListener(() => setState(() {}));
    _dxA = _seq(_dx).animate(_ctrl);
    _dyA = _seq(_dy).animate(_ctrl);
    _scA = _seq(_sc).animate(_ctrl);
    _opA = _seq(_op).animate(_ctrl);
    Future.delayed(widget.data.delay, () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.data.size;
    return Transform.translate(
      offset: Offset(_dxA.value, _dyA.value),
      child: Transform.scale(
        scale: _scA.value,
        child: Opacity(
          opacity: _opA.value.clamp(0.0, 1.0),
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.data.color,
              boxShadow: [
                BoxShadow(
                  color: widget.data.color.withOpacity(0.5),
                  blurRadius: widget.data.glowRadius,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  RING DATA MODEL
// ═══════════════════════════════════════════════════════
class _RingData {
  final double leftFraction;
  final double topFraction;
  final double radius;
  final Duration duration;
  final Duration delay;
  const _RingData({
    required this.leftFraction,
    required this.topFraction,
    required this.radius,
    required this.duration,
    required this.delay,
  });
}

final List<_RingData> _rings = [
  _RingData(
    leftFraction: 0.50,
    topFraction: 0.22,
    radius: 115,
    duration: const Duration(seconds: 20),
    delay: Duration.zero,
  ),
  _RingData(
    leftFraction: 0.22,
    topFraction: 0.58,
    radius: 78,
    duration: const Duration(seconds: 26),
    delay: const Duration(seconds: 3),
  ),
  _RingData(
    leftFraction: 0.72,
    topFraction: 0.38,
    radius: 92,
    duration: const Duration(seconds: 18),
    delay: const Duration(seconds: 6),
  ),
  _RingData(
    leftFraction: 0.38,
    topFraction: 0.78,
    radius: 62,
    duration: const Duration(seconds: 23),
    delay: const Duration(seconds: 2),
  ),
  _RingData(
    leftFraction: 0.82,
    topFraction: 0.68,
    radius: 52,
    duration: const Duration(seconds: 29),
    delay: const Duration(seconds: 5),
  ),
];

// ═══════════════════════════════════════════════════════
//  ANIMATED RING
// ═══════════════════════════════════════════════════════
class _AnimatedRing extends StatefulWidget {
  final _RingData data;
  const _AnimatedRing({required this.data});
  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dy, _op;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.data.duration)
      ..addListener(() => setState(() {}));

    _dy = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _op = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.08, end: 0.20), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.20, end: 0.08), weight: 1),
    ]).animate(_ctrl);

    Future.delayed(widget.data.delay, () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data.radius * 2;
    return Transform.translate(
      offset: Offset(0, _dy.value),
      child: Opacity(
        opacity: _op.value,
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF60A5FA), // translucent blue ring
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ORBITING CURSOR PARTICLES  (drift / lag per particle)
// ═══════════════════════════════════════════════════════
class _OrbitParticle {
  final double orbitRadius;
  final double size;
  final Color color;
  final double speed; // rad/tick  +CW / -CCW
  final double lerpFactor; // how fast it chases cursor  0.02=lazy … 0.08=snappy
  double angle;
  Offset laggedCenter; // each particle has its own drifting anchor

  _OrbitParticle({
    required this.orbitRadius,
    required this.size,
    required this.color,
    required this.speed,
    required this.lerpFactor,
    required this.angle,
    required this.laggedCenter,
  });

  void updateCenter(Offset target) {
    laggedCenter = Offset(
      laggedCenter.dx + (target.dx - laggedCenter.dx) * lerpFactor,
      laggedCenter.dy + (target.dy - laggedCenter.dy) * lerpFactor,
    );
  }

  Offset get position => Offset(
    laggedCenter.dx + cos(angle) * orbitRadius,
    laggedCenter.dy + sin(angle) * orbitRadius,
  );
}

class _MouseParticleTrail extends StatefulWidget {
  const _MouseParticleTrail();
  @override
  State<_MouseParticleTrail> createState() => _MouseParticleTrailState();
}

class _MouseParticleTrailState extends State<_MouseParticleTrail>
    with SingleTickerProviderStateMixin {
  final _canvasKey = GlobalKey();
  late final AnimationController _ticker;
  late final List<_OrbitParticle> _particles;

  Offset _realCursor = const Offset(-999, -999);
  bool _hasMovedOnce = false;

  // ── 30 particles matched to the screenshot ─────────────────────────────
  // Each row: [r, g, b, orbitRadius, size, speedMultiplier, lerpFactor, cw(1/0)]
  static const _specs = <List<num>>[
    // ── bright cyan ───────────────────────────────────────────────────────
    [0x00, 0xD4, 0xE8, 120.0, 8.0, 0.80, 0.030, 1],
    [0x00, 0xD4, 0xE8, 90.0, 4.0, 1.20, 0.055, 1],
    [0x00, 0xD4, 0xE8, 160.0, 6.0, 0.60, 0.025, 0],
    [0x00, 0xD4, 0xE8, 70.0, 3.5, 1.40, 0.065, 1],
    [0x00, 0xD4, 0xE8, 200.0, 5.0, 0.50, 0.020, 0],
    [0x00, 0xD4, 0xE8, 140.0, 7.0, 0.90, 0.035, 1],
    [0x00, 0xD4, 0xE8, 105.0, 3.0, 1.10, 0.060, 0],
    [0x00, 0xD4, 0xE8, 175.0, 4.5, 0.70, 0.028, 1],
    [0x00, 0xD4, 0xE8, 80.0, 5.5, 1.30, 0.050, 0],
    [0x00, 0xD4, 0xE8, 220.0, 4.0, 0.45, 0.018, 1],
    // ── mid cyan ──────────────────────────────────────────────────────────
    [0x06, 0xB6, 0xD4, 150.0, 5.5, 0.65, 0.038, 0],
    [0x06, 0xB6, 0xD4, 100.0, 4.0, 1.00, 0.052, 1],
    [0x06, 0xB6, 0xD4, 190.0, 6.5, 0.55, 0.024, 0],
    [0x06, 0xB6, 0xD4, 75.0, 3.0, 1.50, 0.068, 1],
    [0x06, 0xB6, 0xD4, 165.0, 5.0, 0.72, 0.032, 0],
    // ── blue ──────────────────────────────────────────────────────────────
    [0x3B, 0x82, 0xF6, 135.0, 6.5, 0.75, 0.040, 0],
    [0x3B, 0x82, 0xF6, 95.0, 4.5, 1.10, 0.058, 1],
    [0x3B, 0x82, 0xF6, 180.0, 5.5, 0.60, 0.026, 0],
    [0x3B, 0x82, 0xF6, 65.0, 3.5, 1.60, 0.070, 1],
    [0x3B, 0x82, 0xF6, 210.0, 7.0, 0.48, 0.019, 0],
    // ── deep purple ───────────────────────────────────────────────────────
    [0x7C, 0x3A, 0xED, 155.0, 5.0, 0.55, 0.022, 1],
    [0x7C, 0x3A, 0xED, 110.0, 3.5, 1.05, 0.048, 0],
    [0x7C, 0x3A, 0xED, 195.0, 6.0, 0.50, 0.021, 1],
    [0x7C, 0x3A, 0xED, 85.0, 4.0, 1.25, 0.056, 0],
    [0x7C, 0x3A, 0xED, 145.0, 5.5, 0.68, 0.030, 1],
    // ── violet ────────────────────────────────────────────────────────────
    [0xA8, 0x55, 0xF7, 115.0, 4.5, 1.00, 0.048, 0],
    [0xA8, 0x55, 0xF7, 170.0, 6.0, 0.70, 0.033, 1],
    [0xA8, 0x55, 0xF7, 78.0, 3.0, 1.35, 0.062, 0],
    [0xA8, 0x55, 0xF7, 205.0, 5.0, 0.52, 0.023, 1],
    [0xA8, 0x55, 0xF7, 130.0, 4.0, 0.88, 0.042, 0],
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();

    _particles = _specs.map((s) {
      final baseSpeed = 0.011 + rng.nextDouble() * 0.009;
      final cw = s[7].toInt() == 1;
      return _OrbitParticle(
        orbitRadius: s[3].toDouble() - rng.nextInt(50),
        size: s[4].toDouble(),
        color: Color.fromARGB(255, s[0].toInt(), s[1].toInt(), s[2].toInt()),
        speed: (cw ? 1 : -1) * baseSpeed * s[5].toDouble(),
        lerpFactor: s[6].toDouble(),
        angle: rng.nextDouble() * 2 * pi,
        laggedCenter: const Offset(-999, -999),
      );
    }).toList();

    _ticker =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 16),
          )
          ..addListener(() {
            if (!_hasMovedOnce) return;
            setState(() {
              for (final p in _particles) {
                p.angle += p.speed;
                p.updateCenter(_realCursor);
              }
            });
          })
          ..repeat();
  }

  void _onPointerEvent(PointerEvent event) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(event.position);
    if (!_hasMovedOnce) {
      // Snap all lagged centers on first move so nothing flies from offscreen
      for (final p in _particles) {
        p.laggedCenter = local;
      }
      _hasMovedOnce = true;
    }
    _realCursor = local;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerEvent,
      onPointerHover: _onPointerEvent,
      behavior: HitTestBehavior.translucent,
      child: RepaintBoundary(
        child: CustomPaint(
          key: _canvasKey,
          painter: _OrbitPainter(particles: _particles, visible: _hasMovedOnce),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final List<_OrbitParticle> particles;
  final bool visible;
  const _OrbitPainter({required this.particles, required this.visible});

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    for (final p in particles) {
      canvas.drawCircle(
        p.position,
        p.size / 1.2,
        Paint()
          ..color = p.color.withValues(alpha: 0.92)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => true;
}

// ═══════════════════════════════════════════════════════
//  ParticleBackground — main export widget
// ═══════════════════════════════════════════════════════
/// Wrap any page with this widget:
/// ```dart
/// ParticleBackground(child: YourPage())
/// ```
class ParticleBackground extends StatelessWidget {
  final Widget? child;
  const ParticleBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Layer 0: dark gradient background ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
              colors: [Color(0xFF0A1628), Color(0xFF0D1F3C), Color(0xFF0A1628)],
            ),
          ),
        ),

        // ── Layer 1: floating rings ──
        IgnorePointer(
          child: LayoutBuilder(
            builder: (_, constraints) => Stack(
              children: _rings
                  .map(
                    (r) => Positioned(
                      left: r.leftFraction * constraints.maxWidth - r.radius,
                      top: r.topFraction * constraints.maxHeight - r.radius,
                      child: _AnimatedRing(data: r),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        // ── Layer 2: dot particles ──
        IgnorePointer(
          child: LayoutBuilder(
            builder: (_, constraints) => Stack(
              children: _staticParticles
                  .map(
                    (p) => Positioned(
                      left: p.leftFraction * constraints.maxWidth,
                      top: p.topFraction * constraints.maxHeight,
                      child: _AnimatedParticle(data: p),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        // ── Layer 3: page content ──
        ?child,

        // ── Layer 4: mouse/touch trail ──
        const _MouseParticleTrail(),
      ],
    );
  }
}
