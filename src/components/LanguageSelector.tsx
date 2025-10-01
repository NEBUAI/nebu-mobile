import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Modal,
  FlatList,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { setLanguage } from '@/store/languageSlice';
import { getTheme } from '@/utils/theme';
import { languages, Language } from '@/locales';

interface LanguageSelectorProps {
  visible: boolean;
  onClose: () => void;
}

const LanguageSelector: React.FC<LanguageSelectorProps> = ({ visible, onClose }) => {
  const { i18n } = useTranslation();
  const dispatch = useAppDispatch();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const currentLanguage = useAppSelector((state) => state.language.currentLanguage);
  const theme = getTheme(isDarkMode);

  const handleLanguageChange = async (languageCode: Language) => {
    dispatch(setLanguage(languageCode));
    await i18n.changeLanguage(languageCode);
    onClose();
  };

  const getModalStyle = (): ViewStyle => ({
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  });

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    borderRadius: theme.borderRadius.lg,
    padding: theme.spacing.lg,
    margin: theme.spacing.lg,
    minWidth: 280,
    maxHeight: 400,
    ...theme.shadows.lg,
  });

  const getTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: theme.colors.text,
    textAlign: 'center',
    marginBottom: theme.spacing.lg,
  });

  const getLanguageItemStyle = (isSelected: boolean): ViewStyle => ({
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.sm,
    borderRadius: theme.borderRadius.md,
    backgroundColor: isSelected ? theme.colors.primary + '20' : 'transparent',
    marginBottom: theme.spacing.xs,
  });

  const getLanguageTextStyle = (isSelected: boolean): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: isSelected ? theme.colors.primary : theme.colors.text,
    fontWeight: isSelected ? theme.typography.weights.semibold : theme.typography.weights.regular,
    flex: 1,
    marginLeft: theme.spacing.sm,
  });

  const renderLanguageItem = ({ item }: { item: typeof languages[0] }) => {
    const isSelected = item.code === currentLanguage;

    return (
      <TouchableOpacity
        style={[styles.languageItem, getLanguageItemStyle(isSelected)]}
        onPress={() => handleLanguageChange(item.code)}
        activeOpacity={0.7}
      >
        <Text style={styles.flagEmoji}>
          {item.code === 'es' ? '🇪🇸' : '🇺🇸'}
        </Text>
        <View style={styles.languageInfo}>
          <Text style={[styles.languageText, getLanguageTextStyle(isSelected)]}>
            {item.nativeName}
          </Text>
          <Text style={[styles.languageSubtext, { color: theme.colors.textSecondary }]}>
            {item.name}
          </Text>
        </View>
        {isSelected && (
          <Ionicons
            name="checkmark"
            size={20}
            color={theme.colors.primary}
          />
        )}
      </TouchableOpacity>
    );
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onClose}
    >
      <View style={[styles.modal, getModalStyle()]}>
        <View style={[styles.container, getContainerStyle()]}>
          <Text style={[styles.title, getTitleStyle()]}>
            Seleccionar Idioma
          </Text>
          
          <FlatList
            data={languages}
            keyExtractor={(item) => item.code}
            renderItem={renderLanguageItem}
            showsVerticalScrollIndicator={false}
          />
          
          <TouchableOpacity
            style={[styles.closeButton, { backgroundColor: theme.colors.surface }]}
            onPress={onClose}
            activeOpacity={0.7}
          >
            <Text style={[styles.closeButtonText, { color: theme.colors.text }]}>
              Cerrar
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modal: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  container: {
    borderRadius: 12,
    padding: 24,
    margin: 24,
    minWidth: 280,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 24,
  },
  languageItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 16,
    paddingHorizontal: 8,
    borderRadius: 8,
    marginBottom: 4,
  },
  flagEmoji: {
    fontSize: 24,
  },
  languageInfo: {
    flex: 1,
    marginLeft: 12,
  },
  languageText: {
    fontSize: 16,
  },
  languageSubtext: {
    fontSize: 14,
    marginTop: 2,
  },
  closeButton: {
    marginTop: 16,
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
  },
  closeButtonText: {
    fontSize: 16,
    fontWeight: '500',
  },
});

export default LanguageSelector;
