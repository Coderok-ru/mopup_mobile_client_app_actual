import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран для отображения веб-страницы во внутреннем браузере.
class WebViewView extends StatefulWidget {
  /// Создает экран WebView.
  const WebViewView({
    required this.url,
    required this.title,
    super.key,
  });

  /// URL для загрузки.
  final String url;

  /// Заголовок экрана.
  final String title;

  @override
  State<WebViewView> createState() => _WebViewViewState();
}

class _WebViewViewState extends State<WebViewView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            _injectCSS();
            _hideMenuAndFooter();
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /// Внедряет CSS стили для скрытия элементов.
  Future<void> _injectCSS() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    const String cssScript = '''
      (function() {
        const style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `
          header,
          header *,
          .header,
          .header *,
          .header-style-1,
          .header-style-1 *,
          .sticy-header,
          .sticy-header *,
          [class*="header"],
          [class*="header"] *,
          footer,
          footer *,
          .footer,
          .footer *,
          .order-track-button,
          .order-track-button *,
          .menubox,
          .menubox *,
          [class*="menubox"],
          [class*="menubox"] *,
          .scrollToTopWa,
          .scrollToTopWa *,
          #scrollToTopWa,
          #scrollToTopWa *,
          [id*="scrollToTopWa"],
          [id*="scrollToTopWa"] *,
          .mobile-menu,
          .mobile-menu *,
          .main-menu,
          .main-menu *,
          .mega-menu,
          .mega-menu *,
          .breadcrumb-area,
          .breadcrumb-area *,
          [class*="breadcrumb"] {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
            width: 0 !important;
            overflow: hidden !important;
            padding: 0 !important;
            margin: 0 !important;
            opacity: 0 !important;
            position: absolute !important;
            left: -9999px !important;
          }
        `;
        document.head.appendChild(style);
      })();
    ''';
    try {
      await _controller.runJavaScript(cssScript);
    } catch (e) {
      // Игнорируем ошибки
    }
  }

  /// Скрывает меню и футер на странице через JavaScript.
  Future<void> _hideMenuAndFooter() async {
    // Ждем небольшую задержку, чтобы DOM полностью загрузился
    await Future<void>.delayed(const Duration(milliseconds: 800));
    const String hideScript = '''
      (function() {
        function hideElements() {
          // Скрываем элементы меню и футера через различные селекторы
          const selectors = [
            'header',
            'footer',
            '.header',
            '.footer',
            '.header-style-1',
            '.sticy-header',
            '.menu',
            '.navigation',
            'nav',
            '[class*="header"]',
            '[class*="footer"]',
            '[class*="menu"]',
            '[class*="navigation"]',
            '[id*="header"]',
            '[id*="footer"]',
            '[id*="menu"]',
            '[id*="navigation"]',
            '.order-track-button',
            '.menubox',
            '[class*="menubox"]',
            '[class*="order-track-button"]',
            '#scrollToTopWa',
            '.scrollToTopWa',
            '[id*="scrollToTopWa"]',
            '[class*="scrollToTopWa"]',
            '.mobile-menu',
            '.main-menu',
            '.mega-menu',
            '.breadcrumb-area',
            '[class*="breadcrumb"]',
          ];
          
          // Скрываем все header элементы (включая все варианты)
          const headerSelectors = [
            'header',
            '[tagName="header"]',
            '.header-style-1',
            '.sticy-header',
            '[class*="header"]',
          ];
          
          headerSelectors.forEach(selector => {
            try {
              const headers = document.querySelectorAll(selector);
              headers.forEach(header => {
                if (header) {
                  header.style.display = 'none !important';
                  header.style.visibility = 'hidden !important';
                  header.style.height = '0 !important';
                  header.style.overflow = 'hidden !important';
                  header.style.padding = '0 !important';
                  header.style.margin = '0 !important';
                  // Скрываем все дочерние элементы
                  const children = header.querySelectorAll('*');
                  children.forEach(child => {
                    child.style.display = 'none !important';
                    child.style.visibility = 'hidden !important';
                  });
                }
              });
            } catch (e) {
              console.log('Ошибка при скрытии header: ' + selector);
            }
          });
          
          // Скрываем все содержимое внутри header
          const headerElements = document.querySelectorAll('header, [class*="header"]');
          headerElements.forEach(el => {
            if (el) {
              el.style.display = 'none !important';
              el.style.visibility = 'hidden !important';
              el.style.height = '0 !important';
              el.style.overflow = 'hidden !important';
              el.style.padding = '0 !important';
              el.style.margin = '0 !important';
              const children = el.querySelectorAll('*');
              children.forEach(child => {
                child.style.display = 'none !important';
                child.style.visibility = 'hidden !important';
              });
            }
          });
          
          selectors.forEach(selector => {
            try {
              const elements = document.querySelectorAll(selector);
              elements.forEach(el => {
                if (el) {
                  el.style.display = 'none !important';
                  el.style.visibility = 'hidden !important';
                  el.style.height = '0 !important';
                  el.style.overflow = 'hidden !important';
                  el.style.padding = '0 !important';
                  el.style.margin = '0 !important';
                }
              });
            } catch (e) {
              console.log('Ошибка при скрытии элементов: ' + selector);
            }
          });
        }
        
        // Выполняем скрытие сразу
        hideElements();
        
        // Выполняем скрытие через небольшие задержки (для динамически добавляемых элементов)
        setTimeout(hideElements, 100);
        setTimeout(hideElements, 500);
        setTimeout(hideElements, 1000);
        setTimeout(hideElements, 2000);
        
        // Используем MutationObserver для отслеживания новых элементов
        const observer = new MutationObserver(function(mutations) {
          hideElements();
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true,
          attributes: true,
          attributeFilter: ['class', 'id']
        });
        
        // Также наблюдаем за изменениями в document
        observer.observe(document.documentElement, {
          childList: true,
          subtree: true,
          attributes: true,
          attributeFilter: ['class', 'id']
        });
      })();
    ''';
    try {
      await _controller.runJavaScript(hideScript);
      // Повторяем выполнение скрипта через задержки
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      await _controller.runJavaScript(hideScript);
      await Future<void>.delayed(const Duration(milliseconds: 2000));
      await _controller.runJavaScript(hideScript);
    } catch (e) {
      // Игнорируем ошибки выполнения JavaScript
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: widget.title,
        canPop: true,
        onBackPressed: () => Get.back(),
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

