import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()

  @Builder
  PagesMap(name: string) {
    if (name == 'DialogPage') {
      DialogPage()
    }
  }

  build() {
      Row() {
      Column() {
        Column() {
        }
        Navigation(this.pageStack) {
          Tabs() {
            TabContent() {
Column () {
  Text('首页的内容').fontSize(30)
  Button('Push DialogPage')
    .margin(20)
    .width('80%')
    .onClick(() => {
      this.pageStack.pushPathByName('DialogPage', '');
    })
}
            }.tabBar('ホーム')

            TabContent() {
              Text('推荐的内容').fontSize(30)
            }
            .tabBar('通知')

            TabContent() {
              Text('发现的内容').fontSize(30)
            }
            .tabBar('投稿')
          }
        }.mode(NavigationMode.Stack)
        .title('Main')
        .navDestination(this.PagesMap)
        .width('100%')
      }.height('100%')
    }
  }
}


@Component
export struct DialogPage {
  webviewController: webview.WebviewController = new webview.WebviewController();
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text("Dialog NavDestination")
            .fontSize(20)
            .margin({ bottom: 100 })
          Button("Close").onClick(() => {
            this.pageStack.pop()
          }).width('30%')
          Button('runJavaScriptCodePassed')
            .onClick(() => {
              // 传递runJavaScript侧代码方法。
              this.webviewController.runJavaScript(`function changeColor(){document.getElementById('text').style.color = 'red'}`);
            })
          Web({ src: 'https://google.com', controller: this.webviewController })
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .height('30%')
        .width('80%')
      }.height("100%").width('100%')
    }
    .backgroundColor('rgba(0,0,0,0.5)')
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
  }
}