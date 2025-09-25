import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Image,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { useNavigation } from '@react-navigation/native';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';
import { AnimatedCard } from '@/components';

// Mock data for existing toys - in real app this would come from state/API
// TODO _ REVISAR EL BACKEND PARA IMPLEMENTAR ESTA FUNCIONALIDAD
const mockExistingToys = [
  {
    id: '1',
    name: "pedro's Nebu",
    status: 'Ready to connect',
    avatar: require('@/assets/icon.png'), // Using the squirrel icon as placeholder
  },
];

const WelcomeScreen: React.FC = () => {
  const { t } = useTranslation();
  const navigation = useNavigation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);
  
  const [existingToys] = useState(mockExistingToys);

  const handleBack = () => {
    // Navigate back or handle back action
    navigation.goBack();
  };

  const handleHelp = () => {
    Alert.alert(
      'Ayuda',
      'Esta pantalla te permite configurar un nuevo juguete Nebu o conectarte a uno existente. Selecciona la opción que mejor se adapte a tus necesidades.',
      [{ text: 'Entendido' }]
    );
  };

  const handleSetupNewNebu = () => {
    // Navigate to new Nebu setup flow
    navigation.navigate('PersonalitySetup' as never);
  };

  const handleJoinExistingNebu = () => {
    // Navigate to join existing Nebu flow
    Alert.alert(
      'Unirse a Nebu existente',
      'Esta funcionalidad te permitirá conectarte a un juguete Nebu que ya esté configurado. Próximamente disponible.',
      [{ text: 'Entendido' }]
    );
  };

  const handleDeleteToy = (toyId: string) => {
    Alert.alert(
      'Eliminar juguete',
      '¿Estás seguro de que quieres eliminar este juguete? Esta acción no se puede deshacer.',
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Eliminar', 
          style: 'destructive',
          onPress: () => {
            // Handle toy deletion
            console.log('Deleting toy:', toyId);
          }
        },
      ]
    );
  };

  const renderExistingToyCard = (toy: typeof mockExistingToys[0]) => (
    <AnimatedCard
      key={toy.id}
      animationType="slideIn"
      delay={100}
      hoverLift={true}
      style={styles.toyCard}
    >
      <View style={styles.toyCardContent}>
        <View style={styles.avatarContainer}>
          <Image source={toy.avatar} style={styles.avatar} />
        </View>
        
        <View style={styles.toyInfo}>
          <Text style={[styles.toyName, { color: theme.colors.text }]}>
            {toy.name}
          </Text>
          <Text style={[styles.toyStatus, { color: theme.colors.textSecondary }]}>
            {toy.status}
          </Text>
        </View>
        
        <TouchableOpacity
          style={styles.deleteButton}
          onPress={() => handleDeleteToy(toy.id)}
        >
          <Ionicons name="trash-outline" size={20} color={theme.colors.error} />
        </TouchableOpacity>
      </View>
    </AnimatedCard>
  );

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      {/* Header */}
      <View style={[styles.header, { backgroundColor: theme.colors.background }]}>
        <TouchableOpacity style={styles.headerButton} onPress={handleBack}>
          <Ionicons name="arrow-back" size={24} color={theme.colors.text} />
        </TouchableOpacity>
        
        <Text style={[styles.headerTitle, { color: theme.colors.text }]}>
          Continue Nebu Setup
        </Text>
        
        <TouchableOpacity style={styles.headerButton} onPress={handleHelp}>
          <Ionicons name="help-circle-outline" size={24} color={theme.colors.text} />
        </TouchableOpacity>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Main Content */}
        <View style={styles.content}>
          {/* Subtitle */}
          <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
            Connect these profiles to a physical Nebu to complete setup
          </Text>

          {/* Existing Toys Section */}
          {existingToys.length > 0 && (
            <View style={styles.existingToysSection}>
              {existingToys.map(renderExistingToyCard)}
            </View>
          )}

          {/* Action Buttons */}
          <View style={styles.actionButtons}>
            <TouchableOpacity
              style={[styles.primaryButton, { backgroundColor: theme.colors.primary }]}
              onPress={handleSetupNewNebu}
            >
              <Text style={styles.primaryButtonText}>Set up a new Nebu</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.secondaryButton, { borderColor: theme.colors.border }]}
              onPress={handleJoinExistingNebu}
            >
              <Text style={[styles.secondaryButtonText, { color: theme.colors.text }]}>
                Join an existing Nebu
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
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
    justifyContent: 'space-between',
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
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    flex: 1,
    textAlign: 'center',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
  },
  content: {
    paddingHorizontal: 20,
    paddingBottom: 40,
  },
  subtitle: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 32,
    textAlign: 'center',
  },
  existingToysSection: {
    marginBottom: 40,
  },
  toyCard: {
    borderRadius: 16,
    marginBottom: 16,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  toyCardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
  },
  avatarContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#FFE4B5', // Light orange background
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
  },
  toyInfo: {
    flex: 1,
  },
  toyName: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  toyStatus: {
    fontSize: 14,
  },
  deleteButton: {
    padding: 8,
  },
  actionButtons: {
    gap: 16,
  },
  primaryButton: {
    borderRadius: 12,
    paddingVertical: 16,
    paddingHorizontal: 24,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryButton: {
    borderRadius: 12,
    paddingVertical: 16,
    paddingHorizontal: 24,
    alignItems: 'center',
    borderWidth: 1,
  },
  secondaryButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default WelcomeScreen;
