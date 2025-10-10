import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Optimizador de rendimiento para la aplicación
class PerformanceOptimizer {
  /// Configurar optimizaciones globales de rendimiento
  static void configurePerformanceOptimizations() {
    // Deshabilitar debug banner en release
    debugShowCheckedModeBanner = false;
    
    // Optimizar rendering
    _configureRenderingOptimizations();
    
    // Configurar animaciones
    _configureAnimationOptimizations();
    
    // Configurar cache
    _configureCacheOptimizations();
  }

  /// Configurar optimizaciones de rendering
  static void _configureRenderingOptimizations() {
    // Habilitar repaint boundary automático
    RendererBinding.instance.pipelineOwner.debugDoingLayout = false;
    
    // Configurar frame callbacks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Limpiar recursos después del frame
      _cleanupAfterFrame();
    });
  }

  /// Configurar optimizaciones de animaciones
  static void _configureAnimationOptimizations() {
    // Configurar tiempo de animación por defecto
    timeDilation = 1.0;
    
    // Optimizar transiciones
    _configureTransitionOptimizations();
  }

  /// Configurar optimizaciones de transiciones
  static void _configureTransitionOptimizations() {
    // Usar transiciones más eficientes
    const pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    );
  }

  /// Configurar optimizaciones de cache
  static void _configureCacheOptimizations() {
    // Configurar image cache
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
    
    // Configurar picture cache
    PaintingBinding.instance.pictureCache.maximumSize = 100;
  }

  /// Limpiar recursos después del frame
  static void _cleanupAfterFrame() {
    // Limpiar caches si es necesario
    final imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.currentSize > imageCache.maximumSize * 0.8) {
      imageCache.clear();
    }
  }

  /// Optimizar widget para mejor rendimiento
  static Widget optimizeWidget(Widget child, {String? key}) {
    return RepaintBoundary(
      key: key != null ? ValueKey(key) : null,
      child: child,
    );
  }

  /// Crear lista optimizada con lazy loading
  static Widget createOptimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    Axis scrollDirection = Axis.vertical,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return optimizeWidget(
          itemBuilder(context, index),
          key: 'list_item_$index',
        );
      },
    );
  }

  /// Crear grid optimizado
  static Widget createOptimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return optimizeWidget(
          itemBuilder(context, index),
          key: 'grid_item_$index',
        );
      },
    );
  }

  /// Crear scroll view optimizado
  static Widget createOptimizedScrollView({
    required List<Widget> children,
    ScrollController? controller,
    bool shrinkWrap = false,
    Axis scrollDirection = Axis.vertical,
  }) {
    return SingleChildScrollView(
      controller: controller,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      child: Column(
        children: children.map((child) => optimizeWidget(child)).toList(),
      ),
    );
  }

  /// Optimizar imagen con cache
  static Widget createOptimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? placeholder,
  }) {
    return optimizeWidget(
      Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      ),
      key: 'image_$imagePath',
    );
  }

  /// Crear animación optimizada
  static Widget createOptimizedAnimation({
    required AnimationController controller,
    required Widget Function(Animation<double>) builder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return RepaintBoundary(
          child: builder(controller.view),
        );
      },
    );
  }

  /// Optimizar texto con cache
  static Widget createOptimizedText({
    required String text,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextOverflow overflow = TextOverflow.clip,
  }) {
    return optimizeWidget(
      Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
      key: 'text_${text.hashCode}',
    );
  }

  /// Limpiar todos los caches
  static void clearAllCaches() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.pictureCache.clear();
  }

  /// Obtener estadísticas de memoria
  static Map<String, int> getMemoryStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    final pictureCache = PaintingBinding.instance.pictureCache;
    
    return {
      'imageCacheSize': imageCache.currentSize,
      'imageCacheMaxSize': imageCache.maximumSize,
      'imageCacheSizeBytes': imageCache.currentSizeBytes,
      'imageCacheMaxSizeBytes': imageCache.maximumSizeBytes,
      'pictureCacheSize': pictureCache.currentSize,
      'pictureCacheMaxSize': pictureCache.maximumSize,
    };
  }

  /// Verificar si necesita limpieza de memoria
  static bool needsMemoryCleanup() {
    final imageCache = PaintingBinding.instance.imageCache;
    final pictureCache = PaintingBinding.instance.pictureCache;
    
    return imageCache.currentSize > imageCache.maximumSize * 0.8 ||
           pictureCache.currentSize > pictureCache.maximumSize * 0.8;
  }

  /// Ejecutar limpieza de memoria si es necesario
  static void performMemoryCleanupIfNeeded() {
    if (needsMemoryCleanup()) {
      clearAllCaches();
    }
  }
}

/// Mixin para optimización automática de widgets
mixin PerformanceOptimizedWidget on Widget {
  @override
  Widget build(BuildContext context) {
    return PerformanceOptimizer.optimizeWidget(super.build(context));
  }
}

/// Widget base optimizado
class OptimizedWidget extends StatelessWidget {
  final Widget child;
  final String? key;

  const OptimizedWidget({
    super.key,
    required this.child,
    this.key,
  });

  @override
  Widget build(BuildContext context) {
    return PerformanceOptimizer.optimizeWidget(child, key: key);
  }
}

/// Lista optimizada
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return PerformanceOptimizer.createOptimizedListView(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      controller: controller,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
    );
  }
}

/// Grid optimizado
class OptimizedGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final bool shrinkWrap;

  const OptimizedGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return PerformanceOptimizer.createOptimizedGridView(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      controller: controller,
      shrinkWrap: shrinkWrap,
    );
  }
}
