// @ts-nocheck
import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTranslation } from 'react-i18next';
import { Header, Button } from '@/components';
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';
import { OpenAIVoiceAgent, ConversationMessage } from '@/services/openaiVoiceService';

const VoiceAgentScreen: React.FC = () => {
  const { t } = useTranslation();
  const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
  const theme = getTheme(isDarkMode);

  const [isConnected, setIsConnected] = useState(false);
  const [agentStatus, setAgentStatus] = useState<'idle' | 'listening' | 'processing' | 'speaking' | 'error'>('idle');
  const [conversation, setConversation] = useState<ConversationMessage[]>([]);
  const [textInput, setTextInput] = useState('');
  const [apiKey, setApiKey] = useState('');
  const [showApiKeyInput, setShowApiKeyInput] = useState(true);
  
  const voiceAgent = useRef(new OpenAIVoiceAgent());
  const scrollViewRef = useRef<ScrollView>(null);

  useEffect(() => {
    // Setup callbacks
    voiceAgent.current.onMessage((message) => {
      setConversation(prev => [...prev, message]);
      setTimeout(() => {
        scrollViewRef.current?.scrollToEnd({ animated: true });
      }, 100);
    });

    voiceAgent.current.onStatusChange((status) => {
      setAgentStatus(status);
    });

    return () => {
      voiceAgent.current.disconnect();
    };
  }, []);

  const handleConnect = async () => {
    if (!apiKey.trim()) {
      Alert.alert('Error', 'Por favor ingresa tu API Key de OpenAI');
      return;
    }

    try {
      await voiceAgent.current.initialize({
        apiKey: apiKey.trim(),
        voice: 'nova',
        language: 'es',
      });
      
      setIsConnected(true);
      setShowApiKeyInput(false);
      setConversation(voiceAgent.current.getConversation());
      Alert.alert('¡Conectado!', '🤖 Agente de voz de OpenAI listo. ¡Mantén presionado el botón para hablar!');
    } catch (error) {
      Alert.alert('Error', 'No se pudo conectar con OpenAI. Verifica tu API Key.');
      console.error('Connection error:', error);
    }
  };

  const handleStartListening = async () => {
    if (!isConnected) return;
    try {
      await voiceAgent.current.startListening();
    } catch (error) {
      Alert.alert('Error', 'No se pudo iniciar la grabación');
    }
  };

  const handleStopListening = async () => {
    if (!isConnected) return;
    try {
      await voiceAgent.current.stopListening();
    } catch (error) {
      Alert.alert('Error', 'Error al procesar el audio');
    }
  };

  const handleSendText = async () => {
    if (!textInput.trim() || !isConnected) return;
    
    try {
      await voiceAgent.current.sendTextMessage(textInput.trim());
      setTextInput('');
    } catch (error) {
      Alert.alert('Error', 'Error al enviar mensaje');
    }
  };

  const handleClearConversation = async () => {
    Alert.alert(
      'Limpiar Conversación',
      '¿Estás seguro de que quieres borrar toda la conversación?',
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Limpiar', 
          style: 'destructive',
          onPress: async () => {
            await voiceAgent.current.clearConversation();
            setConversation([]);
          }
        }
      ]
    );
  };

  const getStatusIcon = () => {
    switch (agentStatus) {
      case 'listening': return '🎤';
      case 'processing': return '🧠';
      case 'speaking': return '🔊';
      case 'error': return '❌';
      default: return '🤖';
    }
  };

  const getStatusText = () => {
    switch (agentStatus) {
      case 'listening': return 'Escuchando...';
      case 'processing': return 'Procesando...';
      case 'speaking': return 'Hablando...';
      case 'error': return 'Error';
      default: return 'Listo';
    }
  };

  const getStatusColor = () => {
    switch (agentStatus) {
      case 'listening': return '#4caf50';
      case 'processing': return '#ff9800';
      case 'speaking': return '#2196f3';
      case 'error': return '#f44336';
      default: return theme.colors.textSecondary;
    }
  };

  const getContainerStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.background,
    flex: 1,
  });

  const getCardStyle = (): ViewStyle => ({
    backgroundColor: theme.colors.card,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
    ...theme.shadows.sm,
  });

  const renderMessage = (message: ConversationMessage) => (
    <View key={message.id} style={[
      styles.messageContainer,
      message.role === 'user' ? styles.userMessage : styles.assistantMessage,
      {
        backgroundColor: message.role === 'user' 
          ? theme.colors.primary + '20' 
          : theme.colors.card,
      }
    ]}>
      <View style={styles.messageHeader}>
        <Text style={[styles.messageRole, { color: theme.colors.primary }]}>
          {message.role === 'user' ? '👤 Tú' : '🤖 Asistente'}
        </Text>
        <Text style={[styles.messageTime, { color: theme.colors.textSecondary }]}>
          {new Date(message.timestamp).toLocaleTimeString()}
        </Text>
      </View>
      <Text style={[styles.messageContent, { color: theme.colors.text }]}>
        {message.content}
      </Text>
      {message.audioUrl && (
        <View style={styles.audioIndicator}>
          <Ionicons name="volume-high" size={16} color={theme.colors.primary} />
          <Text style={[styles.audioText, { color: theme.colors.primary }]}>
            Audio disponible
          </Text>
        </View>
      )}
    </View>
  );

  if (showApiKeyInput) {
    return (
      <View style={[styles.container, getContainerStyle()]}>
        <Header title="🤖 Agente de Voz OpenAI" />
        
        <View style={styles.setupContainer}>
          <View style={[styles.setupCard, getCardStyle()]}>
            <Text style={[styles.setupTitle, { color: theme.colors.text }]}>
              Configuración Inicial
            </Text>
            
            <Text style={[styles.setupDescription, { color: theme.colors.textSecondary }]}>
              Para usar el agente de voz necesitas una API Key de OpenAI
            </Text>

            <TextInput
              style={[styles.apiKeyInput, { 
                borderColor: theme.colors.border,
                color: theme.colors.text,
                backgroundColor: theme.colors.background,
              }]}
              placeholder="sk-..."
              placeholderTextColor={theme.colors.textSecondary}
              value={apiKey}
              onChangeText={setApiKey}
              secureTextEntry
              multiline={false}
            />

            <Button
              title="🔗 Conectar con OpenAI"
              onPress={handleConnect}
              variant="primary"
              style={{ marginTop: 16 }}
            />

            <View style={styles.infoSection}>
              <Text style={[styles.infoTitle, { color: theme.colors.text }]}>
                ℹ️ Información
              </Text>
              <Text style={[styles.infoText, { color: theme.colors.textSecondary }]}>
                • Necesitas una cuenta de OpenAI con créditos{'\n'}
                • El agente usa GPT-4 para conversación{'\n'}
                • Whisper para transcripción de voz{'\n'}
                • TTS para síntesis de voz{'\n'}
                • Todo es en tiempo real y bidireccional
              </Text>
            </View>
          </View>
        </View>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView 
      style={[styles.container, getContainerStyle()]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <Header 
        title="🤖 Agente de Voz" 
        rightComponent={
          <TouchableOpacity onPress={handleClearConversation}>
            <Ionicons name="trash-outline" size={24} color={theme.colors.text} />
          </TouchableOpacity>
        }
      />

      {/* Status Bar */}
      <View style={[styles.statusBar, getCardStyle()]}>
        <View style={styles.statusInfo}>
          <Text style={[styles.statusIcon, { fontSize: 24 }]}>
            {getStatusIcon()}
          </Text>
          <View>
            <Text style={[styles.statusText, { color: getStatusColor() }]}>
              {getStatusText()}
            </Text>
            <Text style={[styles.statusSubtext, { color: theme.colors.textSecondary }]}>
              {isConnected ? 'OpenAI conectado' : 'Desconectado'}
            </Text>
          </View>
        </View>
        
        {agentStatus === 'listening' && (
          <View style={styles.listeningAnimation}>
            <View style={[styles.soundWave, styles.wave1]} />
            <View style={[styles.soundWave, styles.wave2]} />
            <View style={[styles.soundWave, styles.wave3]} />
          </View>
        )}
      </View>

      {/* Conversation */}
      <ScrollView
        ref={scrollViewRef}
        style={styles.conversationContainer}
        contentContainerStyle={styles.conversationContent}
        showsVerticalScrollIndicator={false}
      >
        {conversation.length === 0 ? (
          <View style={styles.emptyState}>
            <Text style={[styles.emptyStateIcon, { fontSize: 48 }]}>🗣️</Text>
            <Text style={[styles.emptyStateTitle, { color: theme.colors.text }]}>
              ¡Comienza una conversación!
            </Text>
            <Text style={[styles.emptyStateText, { color: theme.colors.textSecondary }]}>
              Mantén presionado el botón de micrófono para hablar{'\n'}
              o escribe un mensaje abajo
            </Text>
          </View>
        ) : (
          conversation.map(renderMessage)
        )}
      </ScrollView>

      {/* Controls */}
      <View style={[styles.controlsContainer, getCardStyle()]}>
        {/* Voice Button */}
        <View style={styles.voiceButtonContainer}>
          <TouchableOpacity
            style={[
              styles.voiceButton,
              { 
                backgroundColor: agentStatus === 'listening' ? '#4caf50' : theme.colors.primary,
                opacity: isConnected ? 1 : 0.5,
              }
            ]}
            onPressIn={handleStartListening}
            onPressOut={handleStopListening}
            disabled={!isConnected || agentStatus === 'processing' || agentStatus === 'speaking'}
            activeOpacity={0.8}
          >
            <Ionicons 
              name={agentStatus === 'listening' ? 'mic' : 'mic-outline'} 
              size={32} 
              color="white" 
            />
          </TouchableOpacity>
          <Text style={[styles.voiceButtonText, { color: theme.colors.textSecondary }]}>
            Mantén presionado
          </Text>
        </View>

        {/* Text Input */}
        <View style={styles.textInputContainer}>
          <TextInput
            style={[styles.textInput, { 
              borderColor: theme.colors.border,
              color: theme.colors.text,
              backgroundColor: theme.colors.background,
            }]}
            placeholder="Escribe un mensaje..."
            placeholderTextColor={theme.colors.textSecondary}
            value={textInput}
            onChangeText={setTextInput}
            multiline
            maxLength={500}
            editable={isConnected}
          />
          <TouchableOpacity
            style={[styles.sendButton, { 
              backgroundColor: theme.colors.primary,
              opacity: (textInput.trim() && isConnected) ? 1 : 0.5,
            }]}
            onPress={handleSendText}
            disabled={!textInput.trim() || !isConnected}
          >
            <Ionicons name="send" size={20} color="white" />
          </TouchableOpacity>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  setupContainer: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  setupCard: {
    padding: 24,
  },
  setupTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 16,
  },
  setupDescription: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 24,
    lineHeight: 22,
  },
  apiKeyInput: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    fontSize: 14,
    marginBottom: 8,
  },
  infoSection: {
    marginTop: 24,
    padding: 16,
    backgroundColor: 'rgba(0,0,0,0.05)',
    borderRadius: 8,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 14,
    lineHeight: 20,
  },
  statusBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    margin: 16,
    marginBottom: 8,
  },
  statusInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusIcon: {
    marginRight: 12,
  },
  statusText: {
    fontSize: 16,
    fontWeight: '600',
  },
  statusSubtext: {
    fontSize: 12,
  },
  listeningAnimation: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  soundWave: {
    width: 4,
    backgroundColor: '#4caf50',
    marginHorizontal: 1,
    borderRadius: 2,
  },
  wave1: {
    height: 20,
    animationDuration: '1s',
  },
  wave2: {
    height: 15,
    animationDuration: '1.2s',
  },
  wave3: {
    height: 25,
    animationDuration: '0.8s',
  },
  conversationContainer: {
    flex: 1,
    paddingHorizontal: 16,
  },
  conversationContent: {
    paddingBottom: 16,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyStateIcon: {
    marginBottom: 16,
  },
  emptyStateTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 8,
    textAlign: 'center',
  },
  emptyStateText: {
    fontSize: 14,
    textAlign: 'center',
    lineHeight: 20,
  },
  messageContainer: {
    padding: 12,
    borderRadius: 12,
    marginBottom: 8,
  },
  userMessage: {
    alignSelf: 'flex-end',
    maxWidth: '80%',
  },
  assistantMessage: {
    alignSelf: 'flex-start',
    maxWidth: '80%',
  },
  messageHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  messageRole: {
    fontSize: 12,
    fontWeight: '600',
  },
  messageTime: {
    fontSize: 10,
  },
  messageContent: {
    fontSize: 14,
    lineHeight: 20,
  },
  audioIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  audioText: {
    fontSize: 12,
    marginLeft: 4,
  },
  controlsContainer: {
    margin: 16,
    marginTop: 8,
  },
  voiceButtonContainer: {
    alignItems: 'center',
    marginBottom: 16,
  },
  voiceButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
  },
  voiceButtonText: {
    fontSize: 12,
    marginTop: 8,
    textAlign: 'center',
  },
  textInputContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
  },
  textInput: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 12,
    marginRight: 8,
    maxHeight: 100,
    fontSize: 14,
  },
  sendButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default VoiceAgentScreen;

