import { ReactionEmoji } from './ReactionEmoji';

export interface NoteUser {
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
  emojis: ReactionEmoji[];
  onlineStatus: string;
}