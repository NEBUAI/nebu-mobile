import React from 'react';
import {
  TextInput,
  View,
  Text,
  StyleSheet,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { InputProps } from '@/types';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

const Input: React.FC<InputProps> = ({
  placeholder,
  value,
  onChangeText,
  secureTextEntry = false,
  keyboardType = 'default',
  autoCapitalize = 'none',
  error,
}) => {
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const getContainerStyle = (): ViewStyle => ({
    borderWidth: 1,
    borderColor: error ? theme.colors.error : theme.colors.border,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.surface,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
    minHeight: 48,
  });

  const getInputStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.md,
    color: theme.colors.text,
    flex: 1,
  });

  const getErrorStyle = (): TextStyle => ({
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.error,
    marginTop: theme.spacing.xs,
  });

  const getPlaceholderColor = () => theme.colors.placeholder;

  return (
    <View style={styles.container}>
      <View style={[styles.inputContainer, getContainerStyle()]}>
        <TextInput
          style={[styles.input, getInputStyle()]}
          placeholder={placeholder}
          placeholderTextColor={getPlaceholderColor()}
          value={value}
          onChangeText={onChangeText}
          secureTextEntry={secureTextEntry}
          keyboardType={keyboardType}
          autoCapitalize={autoCapitalize}
          autoCorrect={false}
        />
      </View>
      {error && (
        <Text style={[styles.errorText, getErrorStyle()]}>
          {error}
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 8,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  input: {
    flex: 1,
  },
  errorText: {
    marginTop: 4,
  },
});

export default Input;
