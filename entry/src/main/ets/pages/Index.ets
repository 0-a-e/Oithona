import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { AlertDialog } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { asset } from '@kit.AssetStoreKit';
import http from '@ohos.net.http';

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
  @State token: string = ""; // 当前选中Tab的索引
  @State notifications: object[] | [] = [];
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
        .width(190)
        .height(40)
        .onClick(() => this.handleConnect())
      Button('remove token', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(190)
        .height(40)
        .onClick(() => {
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
      Button('set token', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(190)
        .height(40)
        .onClick(() => {
          let query: asset.AssetMap = new Map();
          query.set(asset.Tag.ALIAS, stringToArray('token')); // 指定了关键资产别名，最多查询到一条满足条件的关键资产
          query.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL); // 此处表示需要返回关键资产的所有信息，即属性+明文
          try {
            asset.query(query).then((res: Array<asset.AssetMap>) => {
              for (let i = 0; i < res.length; i++) {
                // parse the secret.
                let secret: Uint8Array = res[i].get(asset.Tag.SECRET) as Uint8Array;
                // parse uint8array to string
                let secretStr: string = arrayToString(secret);
                console.log(`token: ${secretStr}`);
                this.token = secretStr;
                promptAction.showToast({
                  message: `assetからトークンを取得しました。`,
                  duration: 2000
                });

              }
            }).catch((err: BusinessError) => {
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

  handleConnect() {
    router.pushUrl({
      url: 'pages/LoginPage'
    })
  }



  // 通知内容构建函数（示例）
  @Builder
  NotificationContent() {
    Column() {
      Button('get notification', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(190)
        .height(40)
        .onClick(async () => {
          const res = await fetchNotification(this.token);
           this.notifications = res;
        })
      Button('show notification', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(8)
        .backgroundColor(0x317aff)
        .width(190)
        .height(40)
        .onClick(async () => {
        console.log(JSON.stringify(this.notifications));
        })
      List({
        space: 10,
        // scroller: this.scroller
      }) {
        ForEach(this.notifications, (item: NotificationType) => {
          ListItem() {
            NotificationItem({ item: item })

          }
        })
      }
    }
  }

  // 个人中心构建函数（示例）
  @Builder
  ProfileContent() {
    RelativeContainer() {
      Text('ユーザー')
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

// interface GeneratedTypeLiteralInterface_1 {
//   token: string;
// }

interface Emoji {
  name: string;
  url: string;
}

interface User {
  id: string;
  name: string;
  username: string;
  host: string;
  avatarUrl: string;
  avatarBlurhash: string | null;
  avatarColor: string | null;
  isAdmin: boolean;
  isModerator: boolean;
  isBot: boolean;
  isCat: boolean;
  emojis: Emoji[];
  onlineStatus: string;
}

interface Folder {
  id: string;
  createdAt: string;
  name: string;
  foldersCount: number;
  filesCount: number;
  parentId: string | null;
  parent: Folder | null;
}

interface  FileProps {
  width: number;
  height: number;
  orientation: number;
  avgColor: string;
}

interface File {
  id: string;
  createdAt: string;
  name: string;
  type: string;
  md5: string;
  size: number;
  isSensitive: boolean;
  blurhash: string;
  properties: FileProps;
  url: string;
  thumbnailUrl: string;
  comment: string | null;
  folderId: string | null;
  folder: Folder | null;
  userId: string;
  user: User;
}

interface Note {
  id: string;
  createdAt: string;
  text: string | null;
  cw: string | null;
  userId: string;
  user: User;
  replyId: string | null;
  renoteId: string | null;
  reply: Note | null;
  renote: Note | null;
  isHidden: boolean;
  visibility: string;
  mentions: string[];
  visibleUserIds: string[];
  fileIds: string[];
  files: File[];
  tags: string[];
  poll: object; // 実際の仕様に応じて詳細を定義
  channelId: string | null;
  channel: object; // 実際の仕様に応じて詳細を定義
  localOnly: boolean;
  emojis: Emoji[];
  reactions: object; // 実際の反応構造に応じて詳細化
  renoteCount: number;
  repliesCount: number;
  uri: string;
  url: string;
  myReaction: object; // 実際の仕様に応じて詳細を定義
}

interface NotificationType {
  id: string;
  createdAt: string;
  isRead: boolean;
  type: string;
  user: User;
  userId: string;
  note: Note;
  reaction: string;
  choice: number;
  invitation: object; // 実際の招待構造に応じて詳細化
  body: string;
  header: string;
  icon: string;
}
class Header {
  public contentType: string;

  constructor(contentType: string) {
    this.contentType = contentType;
  }
}

  async function fetchNotification(token: string): Promise<[] | [object]> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        `https://msk.seppuku.club/api/i/notifications`,
        {
          method: http.RequestMethod.POST,
          //   expectDataType: Object,
          header: new Header('application/json'),
          extraData:JSON.stringify({ i: token, limit: 20 }),
        }// requestConfig
      );

      if (response.responseCode === 200) {
        const result: [object] = JSON.parse(response.result.toString());
        console.log(JSON.stringify(result));
        return result;
      } else {
        console.error(`请求失败，状态码: ${response.responseCode}, ${response.header}, ${response.result}`);
        return [];
      }
    } catch (e) {
      console.error(`网络请求异常: ${JSON.stringify(e)}`);
      return [];
    } finally {
      httpRequest.destroy();
    }
  }

@Component
struct NotificationItem {
  @Prop item: NotificationType;

  build() {
    ListItem() {
if(this.item.type === "followRequestAccepted"){
  Row()
} else {
      Row() {
        // 左側：ユーザーアバター
        Column() {
          Image(this.item.user.avatarUrl)
            .width(48)
            .height(48)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
            .margin({ right: 12 })
        }

        // メインコンテンツ
        Column() {
          // ヘッダーエリア
          Row() {
            Text(this.item.user.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ right: 8 })

            Text(`@${this.item.user.username}`)
              .fontSize(14)
              .fontColor(0x666666)

            Text(this.formatTime(this.item.createdAt))
              .fontSize(12)
              .fontColor(0x999999)
              .margin({ left: 12 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          // 通知内容
          if (this.item.type === 'follow') {
            Text('あなたをフォローしました')
              .fontSize(14)
              .margin({ top: 4 })
          }

          if (this.item.type === 'reaction') {
            Row() {
              Text(`${this.item.reaction} リアクション:`)
                .fontSize(14)
              Text(this.item.note.text?.substring(0, 20) + '...')
                .fontColor(0x3498db)
                .margin({ left: 8 })
            }
            .margin({ top: 4 })
          }

          if (this.item.type === 'mention') {
            Column() {
              Text('あなたに返信:')
                .fontSize(14)
              Text(this.item.note.text?.substring(0, 50) + '...')
                .fontColor(0x666666)
                .margin({ top: 4 })
            }
          }
        }
        .flexGrow(1)
      }
      .padding(12)
      .backgroundColor(this.item.isRead ? 0xf8f9fa : 0xffffff)
      .borderRadius(12)
      .shadow(this.item.isRead ? 0 : { radius: 4, color: 0x1a000000 })
    }
      } .border({ width: 1, color: 0xe9ecef })
  }

  // 時間フォーマット用ヘルパー
  private formatTime(isoString: string): string {
    // 実際のフォーマット処理を実装
    return '何時間前'; // 例
  }
}


