/**
 * Mobile utility functions for Capacitor
 */

import { Capacitor } from '@capacitor/core';
import { Camera } from '@capacitor/camera';
import { Network } from '@capacitor/network';

/**
 * Check if running on native platform
 */
export const isNativePlatform = () => {
  return Capacitor.isNativePlatform();
};

/**
 * Check if running on Android
 */
export const isAndroid = () => {
  return Capacitor.getPlatform() === 'android';
};

/**
 * Request camera permissions (mobile)
 */
export const requestCameraPermissions = async () => {
  if (isNativePlatform()) {
    try {
      const permission = await Camera.requestPermissions();
      return permission.camera === 'granted';
    } catch (error) {
      console.error('Error requesting camera permissions:', error);
      return false;
    }
  }
  return true; // Web browsers handle permissions differently
};

/**
 * Check network status
 */
export const getNetworkStatus = async () => {
  if (isNativePlatform()) {
    try {
      const status = await Network.getStatus();
      return status.connected;
    } catch (error) {
      console.error('Error checking network status:', error);
      return true; // Assume connected on error
    }
  }
  return navigator.onLine;
};

/**
 * Get device info
 */
export const getDeviceInfo = () => {
  return {
    platform: Capacitor.getPlatform(),
    isNative: Capacitor.isNativePlatform(),
    isAndroid: Capacitor.getPlatform() === 'android',
    isIOS: Capacitor.getPlatform() === 'ios',
    isWeb: Capacitor.getPlatform() === 'web'
  };
};

/**
 * Handle back button on Android
 */
export const setupBackButton = (onBackPress) => {
  if (isAndroid()) {
    // Capacitor App plugin handles back button
    import('@capacitor/app').then(({ App }) => {
      App.addListener('backButton', ({ canGoBack }) => {
        if (!canGoBack) {
          onBackPress();
        } else {
          App.exitApp();
        }
      });
    });
  }
};

