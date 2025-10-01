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

const AgeSetupScreen: React.FC = () => {
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [age, setAge] = useState(4);

  const handleBack = () => {
    navigation.goBack();
  };

  const handleContinue = () => {
    navigation.navigate('WorldInfoSetup' as never);
  };

  const handleAgeChange = (newAge: number) => {
    if (newAge >= 2 && newAge <= 12) {
      setAge(newAge);
    }
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
          <View style={[styles.progressBar, { backgroundColor: theme.colors.primary, width: '66%' }]} />
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
            How old is Pedro?
          </Text>
          
          {/* Context */}
          <Text style={[styles.context, { color: theme.colors.textSecondary }]}>
            This information is essential to ensure we create the best age-appropriate experience for your child.
          </Text>

          {/* Age Display */}
          <View style={styles.ageContainer}>
            <Text style={[styles.ageDisplay, { color: theme.colors.text }]}>
              {age}
            </Text>
          </View>

          {/* Age Range Info */}
          <Text style={[styles.ageRange, { color: theme.colors.textSecondary }]}>
            Please provide your child's current age between 2 and 12
          </Text>

          {/* Age Controls */}
          <View style={styles.ageControls}>
            <TouchableOpacity
              style={[styles.ageButton, { backgroundColor: theme.colors.primary }]}
              onPress={() => handleAgeChange(age - 1)}
              disabled={age <= 2}
            >
              <Ionicons name="remove" size={24} color="#FFFFFF" />
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[styles.ageButton, { backgroundColor: theme.colors.primary }]}
              onPress={() => handleAgeChange(age + 1)}
              disabled={age >= 12}
            >
              <Ionicons name="add" size={24} color="#FFFFFF" />
            </TouchableOpacity>
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
    alignItems: 'center',
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
    marginBottom: 60,
    textAlign: 'center',
  },
  ageContainer: {
    marginBottom: 32,
  },
  ageDisplay: {
    fontSize: 120,
    fontWeight: '900',
    lineHeight: 140,
  },
  ageRange: {
    fontSize: 16,
    marginBottom: 40,
    textAlign: 'center',
  },
  ageControls: {
    flexDirection: 'row',
    gap: 24,
  },
  ageButton: {
    width: 60,
    height: 60,
    borderRadius: 12,
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

export default AgeSetupScreen;
