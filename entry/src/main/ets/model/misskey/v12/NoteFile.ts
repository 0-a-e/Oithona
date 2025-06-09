import { NoteUser } from "./NoteUser";

export interface NoteFile {
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
  user: NoteUser;
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