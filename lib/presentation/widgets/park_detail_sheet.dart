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
  late final WebViewController _webViewController;
  bool _isWebViewLoading = true;
  int _currentImageIndex = 0;
  late final PageController _imagePageController;

  /// 전체 이미지 리스트 (imageUrls 배열이 이미 모든 이미지를 포함)
  List<String> get _allImages {
    return widget.imageUrls.where((url) => url.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    // 웹뷰 컨트롤러 초기화
    if (widget.naviLat != null && widget.naviLng != null) {
      final String htmlString =
          '''
      <!DOCTYPE html>
      <html>
      <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
              body, html { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: #EEEEEE; }
              #staticMap { width: 100%; height: 100%; }
              #errorLog { position: absolute; top:0; left:0; padding: 8px; color: red; font-size: 12px; z-index: 9999; word-wrap: break-word; max-width: 100%; }
          </style>
      </head>
      <body>
          <div id="errorLog"></div>
          <div id="staticMap"></div>
          
          <script>
            // 전역 라우팅 에러 캐치
            window.onerror = function(msg, url, lineNo, columnNo, error) {
                document.getElementById('errorLog').innerHTML += "JS Error: " + msg + "<br/>";
                return false;
            };
            
            function onKakaoError() {
                document.getElementById('errorLog').innerHTML += "JS Error: 카카오 지도 스크립트 로드 차단 (도메인 또는 키 문제)<br/>";
            }
            
            function onKakaoLoaded() {
                kakao.maps.load(function() {
                    try {
                      var position = new kakao.maps.LatLng(${widget.naviLat}, ${widget.naviLng});
                      var mapContainer = document.getElementById('staticMap');
                      var mapOption = { 
                          center: position, 
                          level: 3,
                          draggable: false, /* 드래그 금지 */
                          scrollwheel: false, /* 확대축소 금지 */
                          disableDoubleClickZoom: true
                      };    
                      
                      // 지도 생성
                      var map = new kakao.maps.Map(mapContainer, mapOption);
                      
                      // 순수 HTML/SVG를 활용한 커스텀 마커 + 텍스트 오버레이 (이미지 로드 차단 방지)
                      var svgMarker = '<svg width="36" height="36" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.5 14.8843C7.5 22.162 13.8667 28.1804 16.6848 30.4878C17.0881 30.818 17.2922 30.9851 17.5931 31.0699C17.8274 31.1358 18.1722 31.1358 18.4065 31.0699C18.708 30.985 18.9106 30.8195 19.3154 30.488C22.1335 28.1806 28.4999 22.1627 28.4999 14.8849C28.4999 12.1308 27.3937 9.48908 25.4246 7.54158C23.4554 5.59409 20.7849 4.5 18.0001 4.5C15.2153 4.5 12.5445 5.59425 10.5754 7.54175C8.60625 9.48924 7.5 12.1301 7.5 14.8843Z" fill="#FD8224"/><path d="M23.5928 9.84786C23.5861 9.73318 23.5375 9.62496 23.4563 9.54373C23.375 9.4625 23.2668 9.41393 23.1521 9.40723C18.6914 9.14532 15.1184 10.4883 13.5949 13.0078C13.0669 13.8697 12.8066 14.869 12.8473 15.8789C12.8738 16.5248 13.0052 17.162 13.2363 17.7656C13.2499 17.8028 13.2727 17.8359 13.3025 17.8619C13.3323 17.8879 13.3682 17.9059 13.4069 17.9142C13.4456 17.9226 13.4857 17.921 13.5236 17.9097C13.5615 17.8984 13.5959 17.8776 13.6236 17.8494L18.6041 12.7928C18.6477 12.7492 18.6994 12.7147 18.7563 12.6911C18.8132 12.6675 18.8741 12.6554 18.9357 12.6554C18.9973 12.6554 19.0583 12.6675 19.1152 12.6911C19.1721 12.7147 19.2238 12.7492 19.2674 12.7928C19.3109 12.8363 19.3455 12.888 19.3691 12.9449C19.3926 13.0018 19.4048 13.0628 19.4048 13.1244C19.4048 13.186 19.3926 13.247 19.3691 13.3039C19.3455 13.3608 19.3109 13.4125 19.2674 13.4561L13.8246 18.9809L12.9932 19.8123C12.9067 19.8965 12.8551 20.0101 12.8486 20.1306C12.842 20.2511 12.8811 20.3697 12.958 20.4627C13.0001 20.5115 13.0518 20.551 13.1099 20.5789C13.168 20.6068 13.2312 20.6224 13.2956 20.6248C13.36 20.6271 13.4242 20.6162 13.4841 20.5927C13.5441 20.5691 13.5986 20.5334 13.6441 20.4879L14.6279 19.5041C15.4564 19.9049 16.2926 20.1234 17.1217 20.1527C17.1869 20.1551 17.252 20.1563 17.3168 20.1563C18.261 20.1587 19.1872 19.8986 19.9922 19.4051C22.5117 17.8816 23.8553 14.3092 23.5928 9.84786Z" fill="white"/></svg>';
                      var overlayContent = '<div style="display:flex; flex-direction:column; align-items:center;">' +
                                           '  <div style="background:white; padding:4px 10px; border-radius:20px; border:1px solid #ddd; box-shadow:0px 2px 4px rgba(0,0,0,0.1); font-size:13px; font-weight:bold; color:#333; margin-bottom:4px; white-space:nowrap;">${widget.naviLoc}</div>' +
                                           '  <div>' + svgMarker + '</div>' +
                                           '</div>';
                                           
                      var customOverlay = new kakao.maps.CustomOverlay({
                          position: position,
                          content: overlayContent,
                          yAnchor: 1 // 1: 오버레이의 하단이 좌표에 일치하도록 설정
                      });
                      customOverlay.setMap(map);
                      
                      // iOS 웹뷰 및 바텀시트 애니메이션(대략 300~400ms) 도중 크기 0x0 상태에서 마커 증발 방지
                      // 총 1.5초 동안 주기적으로 갱신하여 언제 렌더링되든 완벽히 중앙에 꽂히도록 강제 보정
                      var retryCount = 0;
                      var layoutInterval = setInterval(function() {
                          map.relayout();
                          map.setCenter(position);
                          
                          // 혹시 레이아웃 변경 전에 그려져서 좌표 바깥으로 날아간 오버레이 재부착
                          customOverlay.setMap(null);
                          customOverlay.setMap(map);
                          
                          retryCount++;
                          if (retryCount >= 10) { // 150ms * 10 = 1.5초 후 종료
                              clearInterval(layoutInterval);
                          }
                      }, 150);
                      
                    } catch (e) {
                        document.getElementById('errorLog').innerHTML += "Map Init Error: " + e.message + "<br/>";
                    }
                });
            }
          </script>
          
          <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${dotenv.env['KAKAO_JS_APP_KEY']}&autoload=false" onload="onKakaoLoaded()" onerror="onKakaoError()"></script>
      </body>
      </html>
      ''';

      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFEEEEEE))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isWebViewLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView Error: ${error.description}');
            },
          ),
        )
        ..setOnConsoleMessage((message) {
          debugPrint('WebView Console: ${message.message}');
        })
        ..loadHtmlString(htmlString, baseUrl: "http://localhost/");
    }
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
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey,
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
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
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
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
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
            color: Colors.white,
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
                    color: Colors.grey[300],
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
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
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
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    height: 1.5,
                                                    color: Colors.black87,
                                                    decoration: TextDecoration
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
                                  style: const TextStyle(
                                    fontSize: 13,
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
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
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
                                            : Colors.black.withValues(
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
                                          color: const Color(0xFFEDEDED),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🔹 카카오 Static Map 썸네일 또는 일반 이미지
                      if (widget.naviLat != null && widget.naviLng != null)
                        Container(
                          width: double.infinity,
                          height: 199.33,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: WebViewWidget(
                                  controller: _webViewController,
                                ),
                              ),
                              if (_isWebViewLoading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 199.33,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.imageUrl.isNotEmpty
                                    ? widget.imageUrl
                                    : "https://picsum.photos/800/600",
                              ),
                              fit: BoxFit.fill,
                            ),
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
                            color: Colors.transparent, // 터치 영역 확장
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
        barrierColor: Colors.black87,
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 배경 탭하면 닫기
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
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
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
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
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
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
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
