import { ReactionEmoji } from './ReactionEmoji';
import { NoteFile } from './NoteFile';
import { NoteUser } from './NoteUser';

export interface Note {
  id: string;
  createdAt: string;
  text: string | null;
  cw: string | null;
  userId: string;
  user: NoteUser;
  replyId: string | null;
  renoteId: string | null;
  reply: Note | null;
  renote: Note | null;
  isHidden: boolean;
  visibility: string;
  mentions: string[];
  visibleUserIds: string[];
  fileIds: string[];
  files: NoteFile[];
  tags: string[];
  poll: object; // 実際の仕様に応じて詳細を定義
  channelId: string | null;
  channel: object; // 実際の仕様に応じて詳細を定義
  localOnly: boolean;
  emojis: ReactionEmoji[];
  reactions: object; // 実際の反応構造に応じて詳細化
  renoteCount: number;
  repliesCount: number;
  uri: string;
  url: string;
  myReaction: object; // 実際の仕様に応じて詳細を定義
}
