import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

const VoiceSetupScreen: React.FC = () => {
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [selectedVoice, setSelectedVoice] = useState<string | null>(null);

  const voiceOptions = [
    {
      id: 'boy',
      title: 'Boy Voice',
      description: 'A friendly male voice',
    },
    {
      id: 'girl',
      title: 'Girl Voice',
      description: 'A cheerful female voice',
    },
    {
      id: 'surprise',
      title: 'Surprise Me',
      description: 'Let Nebu choose a random voice',
    },
  ];

  const handleBack = () => {
    navigation.goBack();
  };

  const handleContinue = () => {
    if (selectedVoice) {
      navigation.navigate('ConnectionSetup' as never);
    }
  };

  const renderVoiceOption = (option: typeof voiceOptions[0]) => {
    const isSelected = selectedVoice === option.id;
    
    return (
      <TouchableOpacity
        key={option.id}
        style={[
          styles.voiceOption,
          {
            backgroundColor: isSelected ? theme.colors.primary : theme.colors.card,
            borderColor: isSelected ? theme.colors.primary : theme.colors.border,
          },
        ]}
        onPress={() => setSelectedVoice(option.id)}
      >
        <View style={styles.voiceOptionContent}>
          <Text
            style={[
              styles.voiceOptionTitle,
              {
                color: isSelected ? '#FFFFFF' : theme.colors.text,
              },
            ]}
          >
            {option.title}
          </Text>
          <Text
            style={[
              styles.voiceOptionDescription,
              {
                color: isSelected ? 'rgba(255,255,255,0.8)' : theme.colors.textSecondary,
              },
            ]}
          >
            {option.description}
          </Text>
        </View>
        
        {isSelected && (
          <View style={styles.selectedIndicator}>
            <Ionicons name="checkmark-circle" size={24} color="#FFFFFF" />
          </View>
        )}
      </TouchableOpacity>
    );
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
          <View style={[styles.progressBar, { backgroundColor: theme.colors.primary, width: '90%' }]} />
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
            Which voice would Pedro like Nebu to have?
          </Text>
          
          {/* Subtitle */}
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            You can change this later in settings.
          </Text>

          {/* Voice Options */}
          <View style={styles.voiceOptionsContainer}>
            {voiceOptions.map(renderVoiceOption)}
          </View>
        </View>
      </ScrollView>

      {/* Continue Button */}
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          style={[
            styles.continueButton,
            {
              backgroundColor: selectedVoice ? theme.colors.primary : theme.colors.border,
            },
          ]}
          onPress={handleContinue}
          disabled={!selectedVoice}
        >
          <Text style={[
            styles.continueButtonText,
            {
              color: selectedVoice ? '#FFFFFF' : theme.colors.textSecondary,
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
  subtitle: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 40,
    textAlign: 'center',
  },
  voiceOptionsContainer: {
    gap: 16,
  },
  voiceOption: {
    borderRadius: 12,
    borderWidth: 2,
    padding: 20,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  voiceOptionContent: {
    flex: 1,
  },
  voiceOptionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  voiceOptionDescription: {
    fontSize: 14,
  },
  selectedIndicator: {
    marginLeft: 16,
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

export default VoiceSetupScreen;
