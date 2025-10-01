import esCommon from './es/common.json';
import enCommon from './en/common.json';

export const resources = {
  es: {
    common: esCommon,
  },
  en: {
    common: enCommon,
  },
};

export const defaultNS = 'common';
export const fallbackLng = 'es';

export type Language = 'es' | 'en';

export const languages: { code: Language; name: string; nativeName: string }[] = [
  { code: 'es', name: 'Spanish', nativeName: 'Español' },
  { code: 'en', name: 'English', nativeName: 'English' },
];
