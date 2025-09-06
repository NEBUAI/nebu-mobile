import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { HeaderProps } from '@/types';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

const Header: React.FC<HeaderProps> = ({
  title,
  showBackButton = false,
  onBackPress,
  rightComponent,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
    paddingTop: 44, // Status bar height
    paddingBottom: theme.spacing.md,
    paddingHorizontal: theme.spacing.md,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  });

  const getTitleStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weights.semibold,
    color: theme.colors.text,
    textAlign: 'center',
    flex: 1,
  });

  const getIconColor = () => theme.colors.text;

  return (
    <View style={[styles.container, getContainerStyle()]}>
      <View style={styles.leftSection}>
        {showBackButton && onBackPress && (
          <TouchableOpacity
            style={styles.backButton}
            onPress={onBackPress}
            activeOpacity={0.7}
          >
            <Ionicons
              name="chevron-back"
              size={24}
              color={getIconColor()}
            />
          </TouchableOpacity>
        )}
      </View>
      
      <Text style={[styles.title, getTitleStyle()]} numberOfLines={1}>
        {title}
      </Text>
      
      <View style={styles.rightSection}>
        {rightComponent}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  leftSection: {
    width: 40,
    alignItems: 'flex-start',
  },
  rightSection: {
    width: 40,
    alignItems: 'flex-end',
  },
  title: {
    flex: 1,
    textAlign: 'center',
  },
  backButton: {
    padding: 8,
    marginLeft: -8,
  },
});

export default Header;
