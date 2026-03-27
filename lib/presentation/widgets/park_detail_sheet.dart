import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/core/utils/kakao_navi_service.dart';
import 'package:soopkomong/presentation/widgets/expandable_text.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/core/theme/app_shadows.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkDetailSheet extends ConsumerStatefulWidget {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> imageUrls; // 추가 이미지 URL 리스트 (imageUrl2, imageUrl3, ...)
  final String address;
  final String information;
  final String tel;
  final String tel1;
  final String tel2;
  final bool isVisited;
  final String naviLoc;
  final double? naviLat;
  final double? naviLng;
  final List<String> petIds;

  const ParkDetailSheet({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.address,
    required this.information,
    required this.tel,
    this.tel1 = '',
    this.tel2 = '',
    required this.isVisited,
    required this.naviLoc,
    required this.petIds,
    this.naviLat,
    this.naviLng,
  });

  @override
  ConsumerState<ParkDetailSheet> createState() => _ParkDetailSheetState();
}

class _ParkDetailSheetState extends ConsumerState<ParkDetailSheet> {
  bool _isLoading = false;
  int _currentImageIndex = 0;
  late final PageController _imagePageController;

  /// 전체 이미지 리스트 (imageUrls 배열이 이미 모든 이미지를 포함)
  List<String> get _allImages {
    return widget.imageUrls.where((url) => url.isNotEmpty).toList();
  }

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    
    final html = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { margin: 0; padding: 0; overflow: hidden; }
        #map { width: 100vw; height: 100vh; }
      </style>
      <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=\${dotenv.env['KAKAO_JS_APP_KEY']}"></script>
    </head>
    <body>
      <div id="map"></div>
      <script>
        var mapContainer = document.getElementById('map');
        var mapOption = {
            center: new kakao.maps.LatLng(\${widget.naviLat ?? 37.566826}, \${widget.naviLng ?? 126.9786567}),
            level: 3
        };
        var map = new kakao.maps.Map(mapContainer, mapOption);
        
        // 커스텀 마커 SVG 이미지 사용
        var imageSrc = 'https://raw.githubusercontent.com/kakao-maps/marker-resource/master/marker_red.png'; // 기본 마커 대체용
        var imageSize = new kakao.maps.Size(32, 32); 
        var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize); 
        
        var markerPosition  = new kakao.maps.LatLng(\${widget.naviLat ?? 37.566826}, \${widget.naviLng ?? 126.9786567}); 
        var marker = new kakao.maps.Marker({
            position: markerPosition,
            image: markerImage
        });
        marker.setMap(map);
      </script>
    </body>
    </html>
    ''';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(html, baseUrl: 'http://localhost');
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  /// 🔹 이미지 갤러리 위젯 빌더
  Widget _buildImageGallery() {
    final images = _allImages;

    // 이미지가 없는 경우 플레이스홀더 표시
    if (images.isEmpty) {
      return SizedBox(
        height: 300,
        child: Container(
          color: AppColors.gray200,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: AppColors.gray500,
              size: 48,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // 페이지뷰 (좌우 스와이프)
          PageView.builder(
            controller: _imagePageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(images, index),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.gray100,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.gray100,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.gray500,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // 이미지 카운터 (우측 상단)
          if (images.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // 인디케이터 도트 (하단 중앙)
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImageIndex == index ? 10 : 8,
                    height: _currentImageIndex == index ? 10 : 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _startNavi() async {
    if (widget.naviLat == null || widget.naviLng == null) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await KakaoNaviService.startNavi(
        naviLoc: widget.naviLoc,
        naviLat: widget.naviLat!,
        naviLng: widget.naviLng!,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.4, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              const SizedBox(height: 12),

              /// 🔹 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 상단 이미지 갤러리
              _buildImageGallery(),

              const SizedBox(height: 20),

              /// 🔹 공원 이름
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.name,
                  style: AppTextStyles.title.copyWith(color: AppColors.gray900),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 공원 소개 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  leading: SvgPicture.asset(
                    'assets/images/Info.svg',
                    width: 20,
                    height: 20,
                  ),
                  title: isEn ? 'About' : '공원 소개',
                  child: ExpandableText(
                    text: widget.description,
                    style: AppTextStyles.subTitleM.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 이용안내 카드
              if (widget.information.isNotEmpty ||
                  widget.tel.isNotEmpty ||
                  widget.tel1.isNotEmpty ||
                  widget.tel2.isNotEmpty) ...[
                Builder(
                  builder: (context) {
                    final allTels = [
                      widget.tel,
                      widget.tel1,
                      widget.tel2,
                    ].where((t) => t.isNotEmpty).toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InfoCard(
                        leading: SvgPicture.asset(
                          'assets/images/Info.svg',
                          width: 20,
                          height: 20,
                        ),
                        title: isEn ? 'Guide' : '이용안내',
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 전화번호 영역
                              if (allTels.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEn ? 'Inquiry' : '문의',
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.gray500,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: allTels
                                            .map(
                                              (t) => GestureDetector(
                                                onTap: () =>
                                                    _showPhonePopup([t], isEn),
                                                child: Text(
                                                  t,
                                                  style: AppTextStyles.label
                                                      .copyWith(
                                                        height: 1.5,
                                                        color:
                                                            AppColors.gray900,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              if (allTels.isNotEmpty &&
                                  widget.information.isNotEmpty)
                                const SizedBox(height: 12),
                              // 이용안내 텍스트 영역
                              if (widget.information.isNotEmpty)
                                Text(
                                  widget.information
                                      .replaceAll('<br>', '\n')
                                      .replaceAll('<br/>', '\n'),
                                  style: AppTextStyles.label.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              /// 🔹 얻을 수 있는 캐릭터 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  leading: SvgPicture.asset(
                    'assets/images/Info.svg',
                    width: 20,
                    height: 20,
                  ),
                  title: isEn ? 'Obtainable Characters' : '얻을 수 있는 캐릭터',
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final templatesAsync = ref.watch(
                            soopkomonTemplatesProvider,
                          );
                          final userCharacters = ref.watch(
                            userSoopkomonProvider,
                          );

                          return Row(
                            children: widget.petIds.isEmpty
                                ? [
                                    Text(
                                      isEn
                                          ? 'No characters available.'
                                          : '얻을 수 있는 숲코몽이 없습니다.',
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ]
                                : widget.petIds.map((petId) {
                                    final template = templatesAsync
                                        .asData
                                        ?.value
                                        .where((t) => t.templateId == petId)
                                        .firstOrNull;
                                    final isAcquired =
                                        userCharacters.value?.any(
                                          (c) => c.templateId == petId,
                                        ) ??
                                        false;

                                    Widget imageWidget = Image.asset(
                                      'assets/images/character_silhouette.png',
                                    );

                                    if (template != null) {
                                      imageWidget = SoopkomonImage(
                                        assetPath: template.actualImagePath,
                                        remoteUrl: template.remoteImagePath,
                                        fit: BoxFit.contain,
                                        color: isAcquired
                                            ? null
                                            : AppColors.black.withValues(
                                                alpha: 0.7,
                                              ),
                                        colorBlendMode: isAcquired
                                            ? null
                                            : BlendMode.srcIn,
                                        errorWidget: Image.asset(
                                          'assets/images/character_silhouette.png',
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.gray100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: imageWidget,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 위치 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        // 카카오맵 웹뷰 영역
                        Container(
                          width: double.infinity,
                          height: 199.33,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.gray100,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            children: [
                              // 웹뷰 (안드로이드/iOS 용 카카오맵)
                              WebViewWidget(controller: _webViewController),
                              // 맵 위치 이동을 막기 위해 위에 투명 덮개를 얹음
                              GestureDetector(
                                onVerticalDragUpdate: (_) {},
                                onHorizontalDragUpdate: (_) {},
                                onTap: () {},
                                child: Container(
                                  color: AppColors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // 🔹 주소 텍스트 영역 (길찾기)
                      GestureDetector(
                        onTap:
                            (widget.naviLat != null && widget.naviLng != null)
                            ? _startNavi
                            : null,
                        child: Opacity(
                          opacity:
                              (widget.naviLat != null && widget.naviLng != null)
                              ? 1.0
                              : 0.3,
                          child: Container(
                            width: double.infinity,
                            color: AppColors.transparent, // 터치 영역 확장
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/Map_pin_area.svg',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.address,
                                    style: AppTextStyles.subTitleM.copyWith(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                if (_isLoading)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhonePopup(List<String> tels, bool isEn) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...tels.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final Uri url = Uri(scheme: 'tel', path: t);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEn ? 'Call $t' : '$t 에 통화 연결',
                          style: AppTextStyles.subTitleM.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gray200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isEn ? 'Cancel' : '취소하기',
                      style: AppTextStyles.subTitleM.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔹 전체화면 이미지 확대 뷰어
  void _showFullScreenImage(List<String> images, int initialIndex) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: AppColors.black.withValues(alpha: 0.87),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageViewer(
            images: images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

/// 전체화면 이미지 뷰어 (핀치 줌 + 스와이프)
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Stack(
        children: [
          // 배경 탭하면 닫기
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: AppColors.transparent),
          ),

          // 이미지 페이지뷰 (핀치 줌 지원)
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.white.withValues(alpha: 0.54),
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // 닫기 버튼 (좌측 상단)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // 이미지 카운터 (우측 상단)
          if (widget.images.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
