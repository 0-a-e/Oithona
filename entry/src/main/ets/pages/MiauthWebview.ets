import { prompt, router } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb';
import uri from "@ohos.uri";

@Entry
@Component
struct MiauthWebview {
  webviewController: webview.WebviewController = new webview.WebviewController();
  @State receivedUrl: string = ''
  @State isLoading: boolean = true

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>

    if (params?.['serverUrl']) {
      this.receivedUrl = params['serverUrl']
    } else {
      // 处理没有参数的情况
      prompt.showToast({ message: '缺少服务器地址' })
      router.back()
    }
  }

  build() {
    Column() {
      // 网页加载容器
      Stack() {
        if (this.receivedUrl) {
          Web({
            src: this.receivedUrl,
            controller: this.webviewController
          })
            .domStorageAccess(true)
            .onPageEnd(e => {
              if (e) {
                console.log('网页加载完成')
                this.isLoading = false
              }
            })
            .onLoadIntercept((event) => {
              if (event) {
                let url: string = event.data.getRequestUrl();
                const urlObj = new uri.URI(url);
                if (url.indexOf('oithona://') === 0) {
                  console.log(url);
                  router.back({
                    url: 'pages/LoginPage',
                    params: {sessionId: urlObj.getQueryValue("session") }
                  });
                }
              }
              return false;
            })
            // .onError(e => {
            //   prompt.showToast({ message: '加载失败' })
            //   this.isLoading = false
            // })
        }

        // 加载指示器
        if (this.isLoading) {
          // Progress()
          //   .width(100)
          //   .height(100)
          //   .color(0x317aff)
        }
      }
      .width('100%')
      .height('90%')

      // 返回按钮
      Button('戻る')
        .onClick(() => router.back())
        .margin(20)
    }
  }
}
