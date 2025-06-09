import { Note } from "./Note";
import { NoteUser } from "./NoteUser";

export interface Notification {
  id: string;
  createdAt: string;
  isRead: boolean;
  type: string;
  user: NoteUser;
  userId: string;
  note: Note;
  reaction: string;
  choice: number;
  invitation: object; // 実際の招待構造に応じて詳細化
  body: string;
  header: string;
  icon: string;
}