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

const ToyNameSetupScreen: React.FC = () => {
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [toyName, setToyName] = useState('Nebu');
  const [phoneticPronunciation, setPhoneticPronunciation] = useState('Neb-u');

  const handleBack = () => {
    navigation.goBack();
  };

  const handleContinue = () => {
    if (toyName.trim()) {
      navigation.navigate('AgeSetup' as never);
    } else {
      Alert.alert('Error', 'Please enter a name for your toy');
    }
  };

  const handlePlayPronunciation = () => {
    // TODO: Implement text-to-speech functionality
    Alert.alert('Play Pronunciation', `Playing: ${phoneticPronunciation}`);
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
          {/* Title */}
          <Text style={[styles.title, { color: theme.colors.text }]}>
            Name your Nebu
          </Text>

          {/* Toy Name Section */}
          <View style={styles.section}>
            <Text style={[styles.sectionLabel, { color: theme.colors.text }]}>
              Toy Name
            </Text>
            <TextInput
              style={[
                styles.input,
                {
                  backgroundColor: theme.colors.card,
                  borderColor: theme.colors.border,
                  color: theme.colors.text,
                },
              ]}
              value={toyName}
              onChangeText={setToyName}
              placeholder="Enter toy name"
              placeholderTextColor={theme.colors.textSecondary}
              autoCapitalize="words"
            />
          </View>

          {/* Phonetic Pronunciation Section */}
          <View style={styles.section}>
            <Text style={[styles.sectionLabel, { color: theme.colors.text }]}>
              Phonetic Pronunciation
            </Text>
            <Text style={[styles.pronunciationHelp, { color: theme.colors.textSecondary }]}>
              Let's make sure Nebu says its name just right! Type it out and hit play to hear it.
            </Text>
            
            <View style={styles.pronunciationContainer}>
              <TextInput
                style={[
                  styles.input,
                  styles.pronunciationInput,
                  {
                    backgroundColor: theme.colors.card,
                    borderColor: theme.colors.border,
                    color: theme.colors.text,
                  },
                ]}
                value={phoneticPronunciation}
                onChangeText={setPhoneticPronunciation}
                placeholder="How should it sound?"
                placeholderTextColor={theme.colors.textSecondary}
              />
              <TouchableOpacity
                style={[styles.playButton, { backgroundColor: theme.colors.primary }]}
                onPress={handlePlayPronunciation}
              >
                <Ionicons name="play" size={20} color="#FFFFFF" />
              </TouchableOpacity>
            </View>
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
  title: {
    fontSize: 24,
    fontWeight: '700',
    lineHeight: 32,
    marginBottom: 40,
    textAlign: 'center',
  },
  section: {
    marginBottom: 32,
  },
  sectionLabel: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  input: {
    borderRadius: 12,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 16,
    fontSize: 16,
  },
  pronunciationHelp: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 16,
  },
  pronunciationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  pronunciationInput: {
    flex: 1,
  },
  playButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
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

export default ToyNameSetupScreen;
