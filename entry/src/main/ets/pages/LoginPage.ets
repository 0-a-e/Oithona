import { router } from '@kit.ArkUI'
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import uri from "@ohos.uri";
import { asset } from '@kit.AssetStoreKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { AlertDialog } from '@kit.ArkUI';
import { MisskeyMeta } from  '../model/misskey/v12/index';

import fs from '@ohos.file.fs';
import preferences from '@ohos.data.preferences';

@Entry
@Component
struct MiauthWebview {
  @State serverAddress: string = '';
  @State sessionId: string = '';
  @State isLoading: boolean = false; // 加载状态

  onPageShow() {
    this.handleParamsUpdate()
  }

  private autoCompleteHttp(url: string): string {
    const trimmed = url.trim();
    if (!trimmed) return '';

    // 已有协议头则直接返回
    if (/^https?:\/\//i.test(trimmed)) {
      return trimmed;
    }

    // 自动添加 http://
    return `http://${trimmed}`;
  }

  // URI 有效性验证
  private isValidUri(url: string): boolean {
    try {
      // 使用鸿蒙 URI 模块验证
      const URI =  new uri.URI(url);
      return !!URI.host; // 必须包含有效域名
    } catch (e) {
      return false;
    }
  }

  // 发送验证请求
  private async verifyInstanceUrl(url: string): Promise<boolean> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${url}/api/meta`,
        {
          method: http.RequestMethod.POST,
          connectTimeout: 5000,
          header: { 'Content-Type': 'application/json' }
        }
      );

      return response.responseCode === 200;
    } catch (e) {
      console.error('验证请求失败:', e);
      return false;
    } finally {
      httpRequest.destroy();
    }
  }

  // 参数处理逻辑抽离为独立方法
  private handleParamsUpdate() {
    const params = router.getParams() as Record<string, string>
    console.log("Received params:", JSON.stringify(params))

    if (params?.['sessionId']) {
      console.log("Existing session detected")
      fetchToken(this.serverAddress, params['sessionId'])
    } else {
      console.log("Generating new session")
      this.sessionId = generateMiauthUUID()
      console.log(`Generated Miauth Session ID: ${this.sessionId}`)
    }

    router.clear()
  }

  private async handleLogin() {
    if (this.isLoading) return;

    // 自动补全协议头
    const fullUrl = this.autoCompleteHttp(this.serverAddress);

    if (!fullUrl || !this.isValidUri(fullUrl)) {
      promptAction.showToast({ message: '有効なURLを入力してください', duration: 2000 });
      return;
    }

    this.isLoading = true;

    try {
      // 发送验证请求
      const isValid = await this.verifyInstanceUrl(fullUrl);

      if (isValid) {
        router.pushUrl({
          url: 'pages/MiauthWebview',
          params: {
            serverUrl: `${fullUrl}/miauth/${this.sessionId}?name=Oithona&callback=oithona://example.com&permission=read:account,write:account,read:blocks,write:blocks,read:drive,write:drive,read:favorites,write:favorites,read:following,write:following,read:messageing,write:messageing,read:mutes,write:mutes,write:notes,read:notifications,write:notificaions,write:reactions,write:votes,read:pages,write:pages,write:page-likes,read:page-likes`
          }
        });
      } else {
        promptAction.showToast({ message: 'Misskeyインスタンスとの接続に失敗しました。正しいMisskeyインスタンスのURLを入力してください。', duration: 2000 });
      }
    } catch (e) {
      promptAction.showToast({ message: 'ネットワークエラーが発生しました。インターネット接続を確認してください。', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }


  tokenSaveFailedDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: 'トークンの保存に失敗しました',
      content: 'アプリを再インストールし、再試行してください。',
      primaryButton: {
        value: 'OK',
        action: () => {
        },
      },
    }),
  })

  build() {
    Column() {
      Text('ようこそ！')
        .fontSize(30)
        .margin({ bottom: 20 })
      TextInput({ text: this.serverAddress, placeholder:"misskeyインスタンスのURLを入力...(例：misskey.io)"})
        .onChange((value: string) => {
        this.serverAddress = value.trim()
      })
      Button('ログイン/登録する')
        .onClick(() => this.handleLogin())
        .enabled(!this.isLoading) // 禁用加载中的按钮

      if (this.isLoading) {
        // Progress()
        //   .color('#007AFF')
        //   .margin({ top: 20 })

    }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

function generateMiauthUUID(): string {
  // 生成 128 位随机数（16字节）
  const buffer = new ArrayBuffer(16);
  const view = new DataView(buffer);

  // 使用加密安全的随机数生成器
  // 注意：HarmonyOS 的 @system.crypto 模块需要申请权限
  for (let i = 0; i < 16; i++) {
    view.setUint8(i, Math.floor(Math.random() * 256));
  }

  // 设置版本号 (version 4)
  view.setUint8(6, (view.getUint8(6) & 0x0f) | 0x40);

  // 设置变体字段 (RFC 4122)
  view.setUint8(8, (view.getUint8(8) & 0x3f) | 0x80);

  // 转换为 UUID 字符串格式
  const hexArray = Array.from(new Uint8Array(buffer), (byte) => {
    return byte.toString(16).padStart(2, '0');
  });

  return [
    hexArray.slice(0, 4).join(''),
    hexArray.slice(4, 6).join(''),
    hexArray.slice(6, 8).join(''),
    hexArray.slice(8, 10).join(''),
    hexArray.slice(10, 16).join('')
  ].join('-');
}


interface GeneratedTypeLiteralInterface_1 {
  token: string;
}

async function fetchToken(serverAddress: string, sessionId: string): Promise<string> {
  const httpRequest = http.createHttp();

  try {
    console.log(`https://${serverAddress}/api/miauth/${sessionId}/check`);
    const response = await httpRequest.request(
      `${serverAddress}/api/miauth/${sessionId}/check`,
      {
        method: http.RequestMethod.POST
      }// requestConfig
    );

    if (response.responseCode === 200) {
      const result: GeneratedTypeLiteralInterface_1 = JSON.parse(response.result.toString());
      console.log(result.token);
      const savetokenRes = await saveToken(result.token);
      if(savetokenRes) {
        promptAction.showToast({
          message: 'トークンの保存に成功しました。',
          duration: 2000
        });
        router.pushUrl({
          url: 'pages/Index' // 需要与实际路由配置一致
        })
      } else {
//this.tokenSaveDialog
        promptAction.showToast({
          message: 'トークンの保存に失敗しました。',
          duration: 2000
        });
      }
      } else {
      console.error(`请求失败，状态码: ${response.responseCode}`);
      return '';
    }
  } catch (e) {
    console.error(`网络请求异常: ${JSON.stringify(e)}`);
    return '';
  } finally {
    httpRequest.destroy();
    return '';
  }
}

async function saveMeta(token: string): Promise<boolean> {
  let attr: asset.AssetMap = new Map();
  attr.set(asset.Tag.SECRET, stringToArray(token));
  attr.set(asset.Tag.ALIAS, stringToArray('token'));
  attr.set(asset.Tag.ACCESSIBILITY, asset.Accessibility.DEVICE_FIRST_UNLOCKED);
  attr.set(asset.Tag.DATA_LABEL_NORMAL_1, stringToArray('miauth_token'));
  try {
    await asset.add(attr); // 等待异步操作完成
    console.info(`Asset added successfully.`);
    return true; // 直接返回操作结果
  } catch (error) {
    const err = error as BusinessError;
    console.error(`Failed to add Asset. Code is ${err.code}, message is ${err.message}`);
    return false;
  }
}


async function saveToken(token: string): Promise<boolean> {
  let attr: asset.AssetMap = new Map();
  attr.set(asset.Tag.SECRET, stringToArray(token));
  attr.set(asset.Tag.ALIAS, stringToArray('token'));
  attr.set(asset.Tag.ACCESSIBILITY, asset.Accessibility.DEVICE_FIRST_UNLOCKED);
  attr.set(asset.Tag.DATA_LABEL_NORMAL_1, stringToArray('miauth_token'));
  try {
    await asset.add(attr); // 等待异步操作完成
    console.info(`Asset added successfully.`);
    return true; // 直接返回操作结果
  } catch (error) {
    const err = error as BusinessError;
    console.error(`Failed to add Asset. Code is ${err.code}, message is ${err.message}`);
    return false;
  }
}

function stringToArray(str: string): Uint8Array {
  let textEncoder = new util.TextEncoder();
  return textEncoder.encodeInto(str);
}
