import { registerPlugin } from '@capacitor/core';

import type { SecureStoragePlugin } from './definitions';

const SecureStorage = registerPlugin<SecureStoragePlugin>('SecureStorage', {
  web: () => import('./web').then(m => new m.SecureStorageWeb()),
});

export * from './definitions';

export const getItemFromSecureStorage = async (
  key: string,
): Promise<string | null> => {
  const getItemResult = await SecureStorage.getItem({ key });
    if (getItemResult === null) {
      return null;
    }
    return getItemResult.data;
};
export const setItemInSecureStorage = async (
  key: string,
  data: string,
): Promise<void> => {
  return await SecureStorage.setItem({ key, data });
};
export const removeItemFromSecureStorage = async (
  key: string,
): Promise<void> => {
  return await SecureStorage.removeItem({ key });
};
export const clearSecureStorage = async (): Promise<void> => {
  return await SecureStorage.clear();
};
export * from './definitions';
