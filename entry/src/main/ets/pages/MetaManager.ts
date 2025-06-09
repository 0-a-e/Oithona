import fs from '@ohos.file.fs';
import preferences from '@ohos.data.preferences';
import util from '@ohos.util';
import { BusinessError } from '@kit.BasicServicesKit';

// メタデータ管理クラス
class MetaManager {
  // 頻繁アクセスフィールド
  private frequentFields = ['uri', 'name', 'maxNoteTextLength'];

  // 大容量データフィールド
  private largeDataFields = ['emojis'];

  // メタデータ保存
  async saveMetaData(meta: MisskeyMeta): Promise<void> {
    // 頻繁アクセスデータ保存
    await this.saveFrequentData({
      uri: meta.uri,
      name: meta.name,
      maxNoteTextLength: meta.maxNoteTextLength
    });

    // 大容量データ保存
    await this.saveLargeData({
      emojis: meta.emojis
    });

    // その他データ保存
    await this.saveOtherData(meta);
  }

  // 頻繁アクセスデータ保存
  private async saveFrequentData(data: {
    uri?: string;
    name?: string;
    maxNoteTextLength?: number;
  }) {
    const pref = await preferences.getPreferences(getContext(), 'frequent_meta');

    if (data.uri) {
      await pref.put('uri', data.uri);
      AppStorage.setOrCreate('serverUrl', data.uri);
    }

    if (data.name) {
      await pref.put('name', data.name);
      AppStorage.setOrCreate('instanceName', data.name);
    }

    if (data.maxNoteTextLength !== undefined) {
      await pref.put('maxNoteTextLength', data.maxNoteTextLength);
    }

    await pref.flush();
  }

  // 大容量データ保存
  private async saveLargeData(data: { emojis?: Emoji[] }) {
    if (data.emojis) {
      const context = getContext();
      const emojiFilePath = `${context.filesDir}/emojis.json`;
      await this.writeJsonFile(emojiFilePath, data.emojis);
    }
  }

  // その他データ保存
  private async saveOtherData(meta: MisskeyMeta) {
    const context = getContext();
    const fullMetaPath = `${context.filesDir}/full_meta.json`;

    // 除外フィールドを明示的に削除
    const otherData = { ...meta };
    delete otherData.uri;
    delete otherData.name;
    delete otherData.maxNoteTextLength;
    delete otherData.emojis;

    await this.writeJsonFile(fullMetaPath, otherData);
  }

  // JSONファイル書き込み
  private async writeJsonFile(path: string, data: any): Promise<void> {
    try {
      const text = JSON.stringify(data);
      const encoder = new util.TextEncoder();
      const uint8Array = encoder.encode(text);

      // ファイル操作 (ArkTS公式ドキュメント準拠)
      const file = await fs.open(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      await fs.write(file.fd, uint8Array.buffer);
      await fs.close(file.fd);
    } catch (error) {
      console.error(`ファイル書き込みエラー: ${path}`, error);
    }
  }

  // JSONファイル読み込み
  private async readJsonFile<T>(path: string): Promise<T | null> {
    try {
      // ファイル存在チェック
      let isExist = false;
      try {
        await fs.access(path);
        isExist = true;
      } catch {
        isExist = false;
      }

      if (!isExist) return null;

      // ファイル読み込み
      const file = await fs.open(path, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(path);
      const arrayBuffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, arrayBuffer);
      await fs.close(file.fd);

      const decoder = new util.TextDecoder('utf-8');
      const text = decoder.decode(new Uint8Array(arrayBuffer));
      return JSON.parse(text) as T;
    } catch (error) {
      console.error(`ファイル読み込みエラー: ${path}`, error);
      return null;
    }
  }

  // メタデータ取得
  async getMetaField(field: string): Promise<any> {
    switch (field) {
      case 'uri':
        return this.getServerUrl();
      case 'name':
        return this.getInstanceName();
      case 'maxNoteTextLength':
        return this.getMaxNoteLength();
      case 'emojis':
        return this.getEmojis();
      default:
        return this.getOtherMetaField(field);
    }
  }

  // サーバーURL取得
  async getServerUrl(): Promise<string> {
    try {
      const context = getContext();
      const pref = await preferences.getPreferences(context, 'frequent_meta');
      return AppStorage.get('serverUrl') || await pref.get('uri', '');
    } catch {
      return '';
    }
  }

  // インスタンス名取得
  async getInstanceName(): Promise<string> {
    try {
      const context = getContext();
      const pref = await preferences.getPreferences(context, 'frequent_meta');
      return AppStorage.get('instanceName') || await pref.get('name', '');
    } catch {
      return '';
    }
  }

  // 最大文字数取得
  async getMaxNoteLength(): Promise<number> {
    try {
      const context = getContext();
      const pref = await preferences.getPreferences(context, 'frequent_meta');
      return await pref.get('maxNoteTextLength', 3000);
    } catch {
      return 3000;
    }
  }

  // 絵文字取得
  async getEmojis(): Promise<Emoji[]> {
    const context = getContext();
    const emojiFilePath = `${context.filesDir}/emojis.json`;
    const data = await this.readJsonFile<Emoji[]>(emojiFilePath);
    return data || [];
  }

  // その他メタデータ取得
  async getOtherMetaField(field: string): Promise<any> {
    const context = getContext();
    const fullMetaPath = `${context.filesDir}/full_meta.json`;
    const data = await this.readJsonFile<Partial<MisskeyMeta>>(fullMetaPath);
    return data ? data[field as keyof MisskeyMeta] : null;
  }
}

// インスタンス管理
let metaManagerInstance: MetaManager | null = null;

export function getMetaManager(): MetaManager {
  if (!metaManagerInstance) {
    metaManagerInstance = new MetaManager();
  }
  return metaManagerInstance;
}