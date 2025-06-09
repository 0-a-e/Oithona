import { MetaEmoji } from './MetaEmoji';

export interface MisskeyMeta {
  maintainerName: string | null;
  maintainerEmail: string | null;
  version: string;
  name: string;
  uri: string; // 頻繁アクセスされる重要項目
  description: string | null;
  langs: string[];
  tosUrl: string | null;
  repositoryUrl: string | null;
  feedbackUrl: string | null;
  defaultDarkTheme: string | null;
  defaultLightTheme: string | null;
  disableRegistration: boolean;
  disableLocalTimeline: boolean;
  disableGlobalTimeline: boolean;
  driveCapacityPerLocalUserMb: number;
  driveCapacityPerRemoteUserMb: number;
  cacheRemoteFiles: boolean;
  emailRequiredForSignup: boolean;
  enableHcaptcha: boolean;
  hcaptchaSiteKey: string | null;
  enableRecaptcha: boolean;
  recaptchaSiteKey: string | null;
  swPublickey: string | null;
  mascotImageUrl: string | null;
  bannerUrl: string | null;
  errorImageUrl: string | null;
  iconUrl: string | null;
  maxNoteTextLength: number;
  emojis: MetaEmoji[]; // 大容量データ（分離保存対象）
  ads: Ad[];
  requireSetup: boolean;
  enableEmail: boolean;
  enableTwitterIntegration: boolean;
  enableGithubIntegration: boolean;
  enableDiscordIntegration: boolean;
  enableServiceWorker: boolean;
  translatorAvailable: boolean;
  proxyAccountName: string | null;
  features: Features;
}

// 広告データ型
interface Ad {
  place: string;
  url: string;
  imageUrl: string;
}

// 機能フラグ型
interface Features {
  registration: boolean;
  localTimeLine: boolean;
  globalTimeLine: boolean;
  elasticsearch: boolean;
  hcaptcha: boolean;
  recaptcha: boolean;
  objectStorage: boolean;
  twitter: boolean;
  github: boolean;
  discord: boolean;
  serviceWorker: boolean;
  miauth: boolean;
}