import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0; // 当前选中Tab的索引

  // 定义工具栏配置
  @State toolbarItems: ToolbarItem[] = [
    {
      value: "ホーム",
      icon: "./image/discover_fill.svg",
      action: () => this.handleTabChange(0)
    },
    {
      value: "通知",
      icon: "./image/bell_fill.svg",
      action: () => this.handleTabChange(1)
    },
    {
      value: "自分",
      icon: "./image/person_crop_circle_fill_1.svg",
      action: () => this.handleTabChange(2)
    }
  ]

  // Tab切换处理
  handleTabChange(index: number) {
    this.currentTabIndex = index;
  }

  // 内容区域组件
  @Builder
  ContentView() {
    if (this.currentTabIndex === 0) {
      // 首页内容
      this.HomeContent()
    } else if (this.currentTabIndex === 1) {
      // 通知内容
      this.NotificationContent()
    } else {
      // 个人中心
      this.ProfileContent()
    }
  }

  // 首页内容构建函数
  @Builder
  HomeContent() {
    RelativeContainer() {
      Button('login', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(90)
        .height(40).onClick(() => this.handleConnect())
    }
    .height('100%')
    .width('100%')
  }

  handleConnect(){
    router.pushUrl({
      url: 'pages/LoginPage'
    })
  }

  // 通知内容构建函数（示例）
  @Builder
  NotificationContent() {
    RelativeContainer() {
      Text('通知内容')
        .fontSize(30)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
  }

  // 个人中心构建函数（示例）
  @Builder
  ProfileContent() {
    RelativeContainer() {
      Text('个人中心')
        .fontSize(30)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
  }

  build() {
    Column() {
      Navigation() {
        this.ContentView() // 动态内容区域
      }
      .mode(NavigationMode.Auto)
      .toolbarConfiguration(this.toolbarItems) // 绑定工具栏配置
 //     .toolbarMenu(false) // 隐藏默认菜单
    }
  }
}
