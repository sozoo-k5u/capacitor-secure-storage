import { WebPlugin } from '@capacitor/core';

import type { SecureStorageGetItemRequest, SecureStorageGetItemResult, SecureStoragePlugin, SecureStorageSetItemRequest } from './definitions';

export class SecureStorageWeb extends WebPlugin implements SecureStoragePlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
  prefix = 'capacitor-storage_';
  async getItem({
    key,
  }: SecureStorageGetItemRequest): Promise<SecureStorageGetItemResult | null> {
    const value = localStorage.getItem(`${this.prefix}${key}`);
    if (value === null) {
      return { data: null };
    }
    return { data: value };
  }

  async setItem({ key, data }: SecureStorageSetItemRequest): Promise<void> {
    localStorage.setItem(`${this.prefix}${key}`, data);
    return Promise.resolve();
  }

  async removeItem({ key }: SecureStorageGetItemRequest): Promise<void> {
    const item = localStorage.getItem(`${this.prefix}${key}`);
    if (item !== null) {
      localStorage.removeItem(key);
    }
    return Promise.resolve();
  }
  async clear(): Promise<void> {
    const { keys } = await this.getPrefixedKeys({ prefix: this.prefix });
    keys.forEach(key => {
      localStorage.removeItem(key);
    });

    return Promise.resolve();
  }

  protected async getPrefixedKeys(options: {
    prefix: string;
  }): Promise<{ keys: string[] }> {
    const keys: string[] = [];

    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);

      if (key?.startsWith(options.prefix)) {
        keys.push(key);
      }
    }

    return Promise.resolve({ keys });
  }
}
