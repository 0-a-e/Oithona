import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { AlertDialog } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { asset } from '@kit.AssetStoreKit';

function stringToArray(str: string): Uint8Array {
  let textEncoder = new util.TextEncoder();
  return textEncoder.encodeInto(str);
}

function arrayToString(arr: Uint8Array): string {
  let textDecoder = util.TextDecoder.create("utf-8", { ignoreBOM: true });
  let str = textDecoder.decodeToString(arr, { stream: false })
  return str;
}


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
    Column() {
      Button('login', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(90)
        .height(40).onClick(() => this.handleConnect())
      Button('remove token', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(90)
        .height(40).onClick(() => {
        let query: asset.AssetMap = new Map();
        query.set(asset.Tag.ALIAS, stringToArray('token')); // 此处指定别名删除单条数据，也可不指定别名删除多条数据
        try {
          asset.remove(query).then(() => {
            console.info(`token removed successfully.`);
            promptAction.showToast({
              message: 'トークンの削除に成功しました。',
              duration: 2000
            });
          }).catch((err: BusinessError) => {
            console.error(`Failed to remove Token. Code is ${err.code}, message is ${err.message}`);
            promptAction.showToast({
              message: `トークンの保存に失敗しました。コード:${err.code}, エラー:${err.message}`,
              duration: 2000
            });
          });
        } catch (error) {
          let err = error as BusinessError;
          console.error(`Failed to remove Asset. Code is ${err.code}, message is ${err.message}`);
          promptAction.showToast({
            message: `トークンの保存に失敗しました。コード:${err.code}, エラー:${err.message}`,
            duration: 2000
          });
        }
      })
      Button('show token', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(90)
        .height(40).onClick(() =>{
        let query: asset.AssetMap = new Map();
        query.set(asset.Tag.ALIAS, stringToArray('token')); // 指定了关键资产别名，最多查询到一条满足条件的关键资产
        query.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);  // 此处表示需要返回关键资产的所有信息，即属性+明文
        try {
          asset.query(query).then((res: Array<asset.AssetMap>) => {
            for (let i = 0; i < res.length; i++) {
              // parse the secret.
              let secret: Uint8Array = res[i].get(asset.Tag.SECRET) as Uint8Array;
              // parse uint8array to string
              let secretStr: string = arrayToString(secret);
              console.log(`token: ${secretStr}`);
              promptAction.showToast({
                message: `トークンの取得に成功しました。トークン:${secretStr}`,
                duration: 2000
              });

            }
          }).catch ((err: BusinessError) => {
            console.error(`Failed to query Asset. Code is ${err.code}, message is ${err.message}`);
            promptAction.showToast({
              message: `トークンの取得に失敗しました。コード:${err.code}, エラー:${err.message}`,
              duration: 2000
            });
          });
        } catch (error) {
          let err = error as BusinessError;
          console.error(`Failed to query Asset. Code is ${err.code}, message is ${err.message}`);
          promptAction.showToast({
            message: `トークンの取得に失敗しました。コード:${err.code}, エラー:${err.message}`,
            duration: 2000
          });
        }
      })
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
