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

const PersonalitySetupScreen: React.FC = () => {
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [selectedOption, setSelectedOption] = useState<string>('depends');

  const personalityOptions = [
    {
      id: 'warm_up',
      title: 'Takes time to warm up',
      description: 'Pedro is shy at first but opens up gradually',
    },
    {
      id: 'depends',
      title: 'Depends on the situation',
      description: 'Pedro adapts based on the context',
    },
    {
      id: 'expressive',
      title: 'Very expressive right away',
      description: 'Pedro is outgoing from the start',
    },
  ];

  const handleBack = () => {
    navigation.goBack();
  };

  const handleContinue = () => {
    // Navigate to next step
    navigation.navigate('FavoritesSetup' as never);
  };

  const renderOption = (option: typeof personalityOptions[0]) => {
    const isSelected = selectedOption === option.id;
    
    return (
      <TouchableOpacity
        key={option.id}
        style={[
          styles.optionButton,
          {
            backgroundColor: isSelected ? theme.colors.primary : theme.colors.card,
            borderColor: isSelected ? theme.colors.primary : theme.colors.border,
          },
        ]}
        onPress={() => setSelectedOption(option.id)}
      >
        <Text
          style={[
            styles.optionText,
            {
              color: isSelected ? '#FFFFFF' : theme.colors.text,
            },
          ]}
        >
          {option.title}
        </Text>
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
          <View style={[styles.progressBar, { backgroundColor: theme.colors.primary, width: '33%' }]} />
        </View>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Main Content */}
        <View style={styles.content}>
          {/* Question */}
          <Text style={[styles.question, { color: theme.colors.text }]}>
            When meeting someone new, does Pedro start chatting right away or take a little time to get comfortable?
          </Text>
          
          {/* Context */}
          <Text style={[styles.context, { color: theme.colors.textSecondary }]}>
            This helps us set the perfect chattiness level for your Nebu.
          </Text>

          {/* Options */}
          <View style={styles.optionsContainer}>
            {personalityOptions.map(renderOption)}
          </View>
        </View>
      </ScrollView>

      {/* Continue Button */}
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          style={[styles.continueButton, { backgroundColor: theme.colors.primary }]}
          onPress={handleContinue}
        >
          <Text style={styles.continueButtonText}>Continue</Text>
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
  question: {
    fontSize: 24,
    fontWeight: '700',
    lineHeight: 32,
    marginBottom: 16,
    textAlign: 'center',
  },
  context: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 40,
    textAlign: 'center',
  },
  optionsContainer: {
    gap: 16,
  },
  optionButton: {
    borderRadius: 12,
    paddingVertical: 20,
    paddingHorizontal: 24,
    borderWidth: 2,
    alignItems: 'center',
  },
  optionText: {
    fontSize: 16,
    fontWeight: '600',
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
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default PersonalitySetupScreen;
