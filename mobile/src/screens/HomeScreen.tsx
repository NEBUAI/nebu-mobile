import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { Header, AnimatedCard, GradientText, ParticleBackground } from '@/components';
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { toggleTheme } from '@/store/themeSlice';
import { getTheme } from '@/utils/theme';

const HomeScreen: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const { user } = useAppSelector((state) => state.auth);
  const theme = getTheme(isDarkMode);

  const handleToggleTheme = () => {
    dispatch(toggleTheme());
  };

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getContentStyle = (): ViewStyle => ({
    padding: theme.spacing.lg,
  });

  const getWelcomeCardStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.lg,
    padding: theme.spacing.lg,
    marginBottom: theme.spacing.lg,
    ...theme.shadows.md,
  });

  const getWelcomeTextStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: theme.colors.text,
    marginBottom: theme.spacing.sm,
  });

  const getSubtitleTextStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: theme.colors.textSecondary,
  });

  const getQuickActionsStyle = (): ViewStyle => ({
    marginBottom: theme.spacing.lg,
  });

  const getSectionTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: theme.colors.text,
    marginBottom: theme.spacing.md,
  });

  const getActionCardStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
    flexDirection: 'row',
    alignItems: 'center',
    ...theme.shadows.sm,
  });

  const getActionIconContainerStyle = (color: string): ViewStyle => ({
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: color,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: theme.spacing.md,
  });

  const getActionTextStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    fontWeight: theme.typography.weights.medium,
    color: theme.colors.text,
    flex: 1,
  });

  const getThemeToggleStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    ...theme.shadows.sm,
  });

  const handleNavigateToScreen = (screenName: string) => {
    switch (screenName) {
      case 'voiceAgent':
        navigation.navigate('VoiceAgent' as never);
        break;
      case 'iotDevices':
        navigation.navigate('IoTDashboard' as never);
        break;
      case 'profile':
        navigation.navigate('Profile' as never);
        break;
      default:
        break;
    }
  };

  const quickActions = [
    { id: 1, title: t('home.voiceAgent'), icon: 'mic-outline', color: theme.colors.primary, screen: 'voiceAgent' },
    { id: 2, title: t('home.iotDevices'), icon: 'hardware-chip-outline', color: theme.colors.tertiary, screen: 'iotDevices' },
    { id: 3, title: t('home.dashboard'), icon: 'analytics-outline', color: theme.colors.secondary, screen: 'iotDevices' },
    { id: 4, title: t('home.settings'), icon: 'settings-outline', color: theme.colors.textSecondary, screen: 'profile' },
  ];

  const renderQuickAction = (action: typeof quickActions[0], index: number) => (
    <AnimatedCard
      key={action.id}
      animationType="slideIn"
      delay={index * 100} // Stagger animation like reference CSS
      hoverLift={true}
      onPress={() => handleNavigateToScreen(action.screen)}
      style={getActionCardStyle()}
    >
      <View style={[styles.actionIconContainer, getActionIconContainerStyle(action.color)]}>
        <Ionicons
          name={action.icon as keyof typeof Ionicons.glyphMap}
          size={20}
          color="#FFFFFF"
        />
      </View>
      <Text style={[styles.actionText, getActionTextStyle()]}>
        {action.title}
      </Text>
      <Ionicons
        name="chevron-forward"
        size={20}
        color={theme.colors.textSecondary}
      />
    </AnimatedCard>
  );

  return (
    <ParticleBackground particleCount={6}>
      <View style={[styles.container, getContainerStyle()]}>
        <Header
          title={t('navigation.home')}
          rightComponent={
            <TouchableOpacity onPress={handleToggleTheme}>
              <Ionicons
                name={isDarkMode ? 'sunny' : 'moon'}
                size={24}
                color={theme.colors.text}
              />
            </TouchableOpacity>
          }
        />
        
        <ScrollView
          style={styles.scrollView}
          contentContainerStyle={[styles.content, getContentStyle()]}
          showsVerticalScrollIndicator={false}
        >
        <AnimatedCard
          animationType="fadeIn"
          delay={0}
          hoverLift={false}
          style={getWelcomeCardStyle()}
        >
          <GradientText
            variant="primary"
            style={getWelcomeTextStyle()}
          >
            {t('home.welcome', { name: user?.name || 'Usuario' })}
          </GradientText>
          <Text style={[styles.subtitleText, getSubtitleTextStyle()]}>
            {t('home.welcomeSubtitle')}
          </Text>
        </AnimatedCard>

        <View style={[styles.quickActions, getQuickActionsStyle()]}>
          <Text style={[styles.sectionTitle, getSectionTitleStyle()]}>
            {t('home.quickActions')}
          </Text>
          {quickActions.map((action, index) => renderQuickAction(action, index))}
        </View>

        </ScrollView>
      </View>
    </ParticleBackground>
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
    paddingBottom: 20,
  },
  welcomeCard: {
    borderRadius: 12,
    padding: 20,
    marginBottom: 24,
  },
  welcomeText: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  subtitleText: {
    fontSize: 16,
  },
  quickActions: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
  },
  actionCard: {
    borderRadius: 8,
    padding: 16,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionIconContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  actionText: {
    fontSize: 16,
    fontWeight: '500',
    flex: 1,
  },
  themeToggle: {
    borderRadius: 8,
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  themeToggleContent: {
    flex: 1,
  },
});

export default HomeScreen;
