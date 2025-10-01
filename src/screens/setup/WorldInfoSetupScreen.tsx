import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  ScrollView,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

const WorldInfoSetupScreen: React.FC = () => {
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [worldInfo, setWorldInfo] = useState('');

  const MIN_WORDS = 10;

  const handleBack = () => {
    navigation.goBack();
  };

  const handleContinue = () => {
    const wordCount = worldInfo.trim().split(/\s+/).filter(word => word.length > 0).length;
    
    if (wordCount >= MIN_WORDS) {
      navigation.navigate('VoiceSetup' as never);
    } else {
      Alert.alert(
        'More Information Needed',
        `Please provide at least ${MIN_WORDS} words about Pedro's world. Currently you have ${wordCount} words.`
      );
    }
  };

  const getWordCount = () => {
    return worldInfo.trim().split(/\s+/).filter(word => word.length > 0).length;
  };

  const isContinueEnabled = () => {
    return getWordCount() >= MIN_WORDS;
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      {/* Header */}
      <View style={[styles.header, { backgroundColor: theme.colors.background }]}>
        <TouchableOpacity style={styles.headerButton} onPress={handleBack}>
          <Ionicons name="arrow-back" size={24} color={theme.colors.text} />
        </TouchableOpacity>
        
        {/* Progress Bar */}
        <View style={[styles.progressContainer, { backgroundColor: theme.colors.border }]}>
          <View style={[styles.progressBar, { backgroundColor: theme.colors.primary, width: '80%' }]} />
        </View>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Main Content */}
        <View style={styles.content}>
          {/* Title */}
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Tell us a little more about Pedro's world
          </Text>
          
          {/* Context */}
          <Text style={[styles.context, { color: theme.colors.textSecondary }]}>
            Nebu only knows as much as you tell him. The more information you share with Nebu, the more personalized your experience will be.
          </Text>

          {/* Word Count Requirement */}
          <Text style={[styles.wordCountRequirement, { color: theme.colors.textSecondary }]}>
            (minimum {MIN_WORDS} words)
          </Text>

          {/* Text Input */}
          <TextInput
            style={[
              styles.textInput,
              {
                backgroundColor: theme.colors.card,
                borderColor: theme.colors.border,
                color: theme.colors.text,
              },
            ]}
            value={worldInfo}
            onChangeText={setWorldInfo}
            placeholder="Tell us about Pedro's interests, family, friends, favorite activities, or anything else that makes Pedro unique..."
            placeholderTextColor={theme.colors.textSecondary}
            multiline
            textAlignVertical="top"
            autoFocus
          />

          {/* Word Count */}
          <Text style={[
            styles.wordCount,
            {
              color: isContinueEnabled() ? theme.colors.success : theme.colors.error,
            },
          ]}>
            {getWordCount()} words
          </Text>
        </View>
      </ScrollView>

      {/* Continue Button */}
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          style={[
            styles.continueButton,
            {
              backgroundColor: isContinueEnabled() ? theme.colors.primary : theme.colors.border,
            },
          ]}
          onPress={handleContinue}
          disabled={!isContinueEnabled()}
        >
          <Text style={[
            styles.continueButtonText,
            {
              color: isContinueEnabled() ? '#FFFFFF' : theme.colors.textSecondary,
            },
          ]}>
            Continue
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 20,
  },
  headerButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.05)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  progressContainer: {
    flex: 1,
    height: 4,
    borderRadius: 2,
  },
  progressBar: {
    height: '100%',
    borderRadius: 2,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 40,
    paddingBottom: 40,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    lineHeight: 32,
    marginBottom: 16,
    textAlign: 'center',
  },
  context: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 16,
    textAlign: 'center',
  },
  wordCountRequirement: {
    fontSize: 14,
    marginBottom: 24,
    textAlign: 'center',
  },
  textInput: {
    borderRadius: 12,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 16,
    fontSize: 16,
    minHeight: 200,
    textAlignVertical: 'top',
  },
  wordCount: {
    fontSize: 14,
    fontWeight: '600',
    marginTop: 8,
    textAlign: 'right',
  },
  bottomContainer: {
    paddingHorizontal: 20,
    paddingBottom: 40,
  },
  continueButton: {
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  continueButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default WorldInfoSetupScreen;
