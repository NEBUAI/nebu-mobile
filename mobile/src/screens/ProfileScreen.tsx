import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { Header, Button, LanguageSelector } from '@/components';
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { logout } from '@/store/authSlice';
import { getTheme } from '@/utils/theme';

const ProfileScreen: React.FC = () => {
  const [showLanguageSelector, setShowLanguageSelector] = useState(false);
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const { user } = useAppSelector((state) => state.auth);
  const theme = getTheme(isDarkMode);

  const handleLogout = () => {
    Alert.alert(
      t('auth.logout'),
      t('auth.logoutConfirm'),
      [
        {
          text: t('common.cancel'),
          style: 'cancel',
        },
        {
          text: t('auth.logout'),
          style: 'destructive',
          onPress: () => dispatch(logout()),
        },
      ]
    );
  };

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getContentStyle = (): ViewStyle => ({
    padding: theme.spacing.lg,
  });

  const getProfileHeaderStyle = (): ViewStyle => ({
    alignItems: 'center',
    marginBottom: theme.spacing.xl,
  });

  const getAvatarStyle = (): ViewStyle => ({
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: theme.colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: theme.spacing.md,
  });

  const getNameStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.xl,
    fontWeight: theme.typography.weights.bold,
    color: theme.colors.text,
    marginBottom: theme.spacing.xs,
  });

  const getEmailStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: theme.colors.textSecondary,
  });

  const getMenuItemStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
    flexDirection: 'row',
    alignItems: 'center',
    ...theme.shadows.sm,
  });

  const getMenuIconContainerStyle = (): ViewStyle => ({
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: theme.colors.surface,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: theme.spacing.md,
  });

  const getMenuTextStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    fontWeight: theme.typography.weights.medium,
    color: theme.colors.text,
    flex: 1,
  });

  const getSectionTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: theme.colors.text,
    marginBottom: theme.spacing.md,
    marginTop: theme.spacing.lg,
  });

  const menuItems = [
    { id: 1, title: t('profile.editProfile'), icon: 'person-outline' },
    { id: 2, title: t('profile.notifications'), icon: 'notifications-outline' },
    { id: 3, title: t('profile.privacy'), icon: 'shield-outline' },
    { id: 4, title: t('profile.language'), icon: 'language-outline', onPress: () => setShowLanguageSelector(true) },
  ];

  const supportItems = [
    { id: 5, title: t('profile.helpCenter'), icon: 'help-circle-outline' },
    { id: 6, title: t('profile.contactSupport'), icon: 'mail-outline' },
    { id: 7, title: t('profile.termsConditions'), icon: 'document-text-outline' },
    { id: 8, title: t('profile.aboutNebu'), icon: 'information-circle-outline' },
  ];

  const renderMenuItem = (item: typeof menuItems[0]) => (
    <TouchableOpacity
      key={item.id}
      style={[styles.menuItem, getMenuItemStyle()]}
      activeOpacity={0.7}
      onPress={item.onPress}
    >
      <View style={[styles.menuIconContainer, getMenuIconContainerStyle()]}>
        <Ionicons
          name={item.icon as keyof typeof Ionicons.glyphMap}
          size={20}
          color={theme.colors.text}
        />
      </View>
      <Text style={[styles.menuText, getMenuTextStyle()]}>
        {item.title}
      </Text>
      <Ionicons
        name="chevron-forward"
        size={20}
        color={theme.colors.textSecondary}
      />
    </TouchableOpacity>
  );

  return (
    <View style={[styles.container, getContainerStyle()]}>
      <Header title={t('profile.title')} />
      
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={[styles.content, getContentStyle()]}
        showsVerticalScrollIndicator={false}
      >
        <View style={[styles.profileHeader, getProfileHeaderStyle()]}>
          <View style={[styles.avatar, getAvatarStyle()]}>
            <Text style={styles.avatarText}>
              {user?.name?.charAt(0).toUpperCase() || 'U'}
            </Text>
          </View>
          <Text style={[styles.name, getNameStyle()]}>
            {user?.name || 'Usuario'}
          </Text>
          <Text style={[styles.email, getEmailStyle()]}>
            {user?.email || 'usuario@ejemplo.com'}
          </Text>
        </View>

        <Text style={[styles.sectionTitle, getSectionTitleStyle()]}>
          {t('profile.accountSettings')}
        </Text>
        {menuItems.map(renderMenuItem)}

        <Text style={[styles.sectionTitle, getSectionTitleStyle()]}>
          {t('profile.support')}
        </Text>
        {supportItems.map(renderMenuItem)}

        <View style={styles.logoutContainer}>
          <Button
            title={t('auth.logout')}
            onPress={handleLogout}
            variant="outline"
            size="large"
          />
        </View>
      </ScrollView>
      
      <LanguageSelector
        visible={showLanguageSelector}
        onClose={() => setShowLanguageSelector(false)}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingBottom: 40,
  },
  profileHeader: {
    alignItems: 'center',
    marginBottom: 32,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  avatarText: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  name: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  email: {
    fontSize: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
    marginTop: 24,
  },
  menuItem: {
    borderRadius: 8,
    padding: 16,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  menuIconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  menuText: {
    fontSize: 16,
    fontWeight: '500',
    flex: 1,
  },
  logoutContainer: {
    marginTop: 32,
  },
});

export default ProfileScreen;
