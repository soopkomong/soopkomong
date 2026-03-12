import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/utils/kakao_navi_service.dart';
import 'package:soopkomong/presentation/widgets/expandable_text.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParkDetailSheet extends ConsumerStatefulWidget {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String information;
  final String tel;
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
    required this.address,
    required this.information,
    required this.tel,
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

  @override
  void initState() {
    super.initState();
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
                      var svgMarker = '<svg width="24" height="35" viewBox="0 0 24 35" xmlns="http://www.w3.org/2000/svg"><path d="M12 0C5.4 0 0 5.4 0 12c0 9 12 23 12 23s12-14 12-23C24 5.4 18.6 0 12 0zm0 17c-2.8 0-5-2.2-5-5s2.2-5 5-5 5 2.2 5 5-2.2 5-5 5z" fill="#FF4B4B"/></svg>';
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

              /// 🔹 상단 이미지
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        widget.imageUrl.isNotEmpty
                            ? widget.imageUrl
                            : 'https://picsum.photos/800/600',
                        fit: BoxFit.cover,
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
                    ),

                    /// 이미지 수
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
                        child: const Text(
                          '1/1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    /// 이미지 인디케이터
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 공원 이름
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 공원 소개 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  leading: const Icon(Icons.description_outlined),
                  title: '공원 소개',
                  child: ExpandableText(
                    text: widget.description,
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 이용안내 카드
              if (widget.information.isNotEmpty || widget.tel.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InfoCard(
                    leading: Image.asset(
                      'assets/images/character_silhouette.png',
                      width: 24,
                    ),
                    title: '이용안내',
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '${widget.tel.isNotEmpty ? '${widget.tel}\n\n' : ''}${widget.information}'
                            .trim(),
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              /// 🔹 얻을 수 있는 캐릭터 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  leading: Image.asset(
                    'assets/images/character_silhouette.png',
                    width: 24,
                  ),
                  title: '얻을 수 있는 캐릭터',
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
                                    const Text(
                                      '얻을 수 있는 숲코몽이 없습니다.',
                                      style: TextStyle(
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
                                    final isAcquired = userCharacters.any(
                                      (c) => c.templateId == petId,
                                    );

                                    Widget imageWidget = Image.asset(
                                      'assets/images/character_silhouette.png',
                                    );

                                    if (template != null &&
                                        template.actualImagePath.isNotEmpty) {
                                      imageWidget = Image.asset(
                                        template.actualImagePath,
                                        color: isAcquired
                                            ? null
                                            : Colors.black.withValues(
                                                alpha: 0.7,
                                              ),
                                        colorBlendMode: isAcquired
                                            ? null
                                            : BlendMode.srcIn,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/character_silhouette.png',
                                          );
                                        },
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
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 4,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ],
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
                                const Icon(Icons.location_on_outlined),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.address,
                                    style: const TextStyle(
                                      color: Color(0xFF191919),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                      overflow: TextOverflow.ellipsis,
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
}
