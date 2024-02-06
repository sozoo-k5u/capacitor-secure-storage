export interface SecureStoragePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  
  getItem: (
    request: SecureStorageGetItemRequest,
  ) => Promise<SecureStorageGetItemResult | null>;

  setItem: (request: SecureStorageSetItemRequest) => Promise<void>;

  removeItem: (request: SecureStorageGetItemRequest) => Promise<void>;

  clear: () => Promise<void>;
}
export interface SecureStorageGetItemResult {
  data: string | null;
}
export interface SecureStorageGetItemRequest {
  key: string;
}
export interface SecureStorageSetItemRequest {
  key: string;
  data: string;
}
