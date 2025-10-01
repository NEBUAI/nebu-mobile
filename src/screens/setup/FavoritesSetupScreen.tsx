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

const FavoritesSetupScreen: React.FC = () => {
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [selectedColor, setSelectedColor] = useState<string | null>(null);

  const colorOptions = [
    { id: 'red', color: '#FF0000', name: 'Red' },
    { id: 'orange', color: '#FF8C00', name: 'Orange' },
    { id: 'yellow', color: '#FFD700', name: 'Yellow' },
    { id: 'green', color: '#00FF00', name: 'Green' },
    { id: 'blue', color: '#0000FF', name: 'Blue' },
    { id: 'purple', color: '#800080', name: 'Purple' },
    { id: 'brown', color: '#A52A2A', name: 'Brown' },
    { id: 'black', color: '#000000', name: 'Black' },
    { id: 'pink', color: '#FFC0CB', name: 'Light Pink' },
    { id: 'beige', color: '#F5F5DC', name: 'Beige' },
    { id: 'mint', color: '#98FB98', name: 'Mint Green' },
    { id: 'light_blue', color: '#ADD8E6', name: 'Light Blue' },
    { id: 'lavender', color: '#E6E6FA', name: 'Light Lavender' },
    { id: 'gold', color: '#FFD700', name: 'Gold' },
    { id: 'white', color: '#FFFFFF', name: 'White' },
  ];

  const handleBack = () => {
    navigation.goBack();
  };

  const handleContinue = () => {
    if (selectedColor) {
      navigation.navigate('ToyNameSetup' as never);
    }
  };

  const renderColorOption = (colorOption: typeof colorOptions[0]) => {
    const isSelected = selectedColor === colorOption.id;
    
    return (
      <TouchableOpacity
        key={colorOption.id}
        style={[
          styles.colorOption,
          {
            backgroundColor: colorOption.color,
            borderColor: isSelected ? theme.colors.primary : colorOption.color === '#FFFFFF' ? theme.colors.border : 'transparent',
            borderWidth: isSelected ? 3 : colorOption.color === '#FFFFFF' ? 1 : 0,
          },
        ]}
        onPress={() => setSelectedColor(colorOption.id)}
      >
        {isSelected && (
          <View style={styles.selectedIndicator}>
            <Ionicons name="checkmark" size={16} color="#FFFFFF" />
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
            Tell us some of Pedro's favorites
          </Text>
          
          {/* Subtitle */}
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            These details help Nebu create more personalized experiences. You can always update this later.
          </Text>

          {/* Color Section */}
          <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
            Favorite Color
          </Text>

          {/* Color Grid */}
          <View style={styles.colorGrid}>
            {colorOptions.map(renderColorOption)}
          </View>
        </View>
      </ScrollView>

      {/* Continue Button */}
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          style={[
            styles.continueButton,
            {
              backgroundColor: selectedColor ? theme.colors.primary : theme.colors.border,
            },
          ]}
          onPress={handleContinue}
          disabled={!selectedColor}
        >
          <Text style={[
            styles.continueButtonText,
            {
              color: selectedColor ? '#FFFFFF' : theme.colors.textSecondary,
            },
          ]}>
            {selectedColor ? 'Continue' : 'Favorite Color Required'}
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
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 24,
  },
  colorGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 16,
    justifyContent: 'space-between',
  },
  colorOption: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  selectedIndicator: {
    position: 'absolute',
    top: 2,
    right: 2,
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: 'rgba(0,0,0,0.6)',
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
    fontSize: 16,
    fontWeight: '600',
  },
});

export default FavoritesSetupScreen;
