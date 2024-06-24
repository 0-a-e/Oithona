@Entry
@Component
struct Index {
  @State message: string = 'Hello World'

  build() {
    Row() {
      Column() {
        Tabs() {
          TabContent() {
            Text('首页的内容').fontSize(30)
          }
          .tabBar('ホーム')

          TabContent() {
            Text('推荐的内容').fontSize(30)
          }
          .tabBar('通知')

          TabContent() {
            Text('发现的内容').fontSize(30)
          }
          .tabBar('投稿')

        }
      }
      .width('100%')
    }
    .height('100%')
  }
}