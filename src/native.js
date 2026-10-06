// Puente entre la web y los plugins nativos de Capacitor.
// "npm run build" lo empaqueta en www/native.js, que index.html carga antes que la app.
import { Capacitor } from '@capacitor/core';
import { LocalNotifications } from '@capacitor/local-notifications';
import { Preferences } from '@capacitor/preferences';
import { SplashScreen } from '@capacitor/splash-screen';
import { StatusBar, Style } from '@capacitor/status-bar';

window.HorarioNative = { Capacitor, LocalNotifications, Preferences, SplashScreen, StatusBar, Style };
