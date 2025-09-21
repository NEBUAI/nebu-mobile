// @ts-nocheck
import OpenAI from 'openai';
import { Audio } from 'expo-av';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface VoiceAgentConfig {
  apiKey: string;
  model?: string;
  voice?: 'alloy' | 'echo' | 'fable' | 'onyx' | 'nova' | 'shimmer';
  language?: string;
}

export interface ConversationMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
  audioUrl?: string;
}

export class OpenAIVoiceAgent {
  private openai: OpenAI | null = null;
  private isListening = false;
  private recording: Audio.Recording | null = null;
  private sound: Audio.Sound | null = null;
  private conversation: ConversationMessage[] = [];
  private onMessageCallback?: (message: ConversationMessage) => void;
  private onStatusCallback?: (status: 'idle' | 'listening' | 'processing' | 'speaking' | 'error') => void;

  constructor() {
    this.initializeAudio();
  }

  private async initializeAudio() {
    try {
      await Audio.requestPermissionsAsync();
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: true,
        playsInSilentModeIOS: true,
        staysActiveInBackground: true,
        shouldDuckAndroid: true,
        playThroughEarpieceAndroid: false,
      });
    } catch (error) {
      console.error('Error initializing audio:', error);
    }
  }

  async initialize(config: VoiceAgentConfig): Promise<void> {
    try {
      this.openai = new OpenAI({
        apiKey: config.apiKey,
      });

      // Load conversation history
      await this.loadConversationHistory();
      
      this.onStatusCallback?.('idle');
    } catch (error) {
      console.error('Error initializing OpenAI:', error);
      this.onStatusCallback?.('error');
      throw error;
    }
  }

  private async loadConversationHistory(): Promise<void> {
    try {
      const history = await AsyncStorage.getItem('voice_conversation_history');
      if (history) {
        this.conversation = JSON.parse(history);
      }
    } catch (error) {
      console.error('Error loading conversation history:', error);
    }
  }

  private async saveConversationHistory(): Promise<void> {
    try {
      await AsyncStorage.setItem('voice_conversation_history', JSON.stringify(this.conversation));
    } catch (error) {
      console.error('Error saving conversation history:', error);
    }
  }

  async startListening(): Promise<void> {
    if (this.isListening || !this.openai) return;

    try {
      this.onStatusCallback?.('listening');
      this.isListening = true;

      // Stop any current playback
      if (this.sound) {
        await this.sound.stopAsync();
        await this.sound.unloadAsync();
        this.sound = null;
      }

      // Start recording
      this.recording = new Audio.Recording();
      await this.recording.prepareToRecordAsync({
        android: {
          extension: '.m4a',
          outputFormat: Audio.RECORDING_OPTION_ANDROID_OUTPUT_FORMAT_MPEG_4,
          audioEncoder: Audio.RECORDING_OPTION_ANDROID_AUDIO_ENCODER_AAC,
          sampleRate: 44100,
          numberOfChannels: 2,
          bitRate: 128000,
        },
        ios: {
          extension: '.m4a',
          outputFormat: Audio.RECORDING_OPTION_IOS_OUTPUT_FORMAT_MPEG4AAC,
          audioQuality: Audio.RECORDING_OPTION_IOS_AUDIO_QUALITY_HIGH,
          sampleRate: 44100,
          numberOfChannels: 2,
          bitRate: 128000,
          linearPCMBitDepth: 16,
          linearPCMIsBigEndian: false,
          linearPCMIsFloat: false,
        },
      });

      await this.recording.startAsync();
    } catch (error) {
      console.error('Error starting recording:', error);
      this.onStatusCallback?.('error');
      this.isListening = false;
    }
  }

  async stopListening(): Promise<void> {
    if (!this.isListening || !this.recording) return;

    try {
      this.onStatusCallback?.('processing');
      this.isListening = false;

      await this.recording.stopAndUnloadAsync();
      const uri = this.recording.getURI();
      
      if (uri) {
        await this.processAudioInput(uri);
      }
    } catch (error) {
      console.error('Error stopping recording:', error);
      this.onStatusCallback?.('error');
    } finally {
      this.recording = null;
    }
  }

  private async processAudioInput(audioUri: string): Promise<void> {
    if (!this.openai) return;

    try {
      // Convert audio to text using Whisper
      const formData = new FormData();
      formData.append('file', {
        uri: audioUri,
        type: 'audio/m4a',
        name: 'recording.m4a',
      } as any);
      formData.append('model', 'whisper-1');
      formData.append('language', 'es'); // Spanish support

      const transcription = await this.openai.audio.transcriptions.create({
        file: formData.get('file') as any,
        model: 'whisper-1',
        language: 'es',
      });

      const userMessage: ConversationMessage = {
        id: Date.now().toString(),
        role: 'user',
        content: transcription.text,
        timestamp: Date.now(),
        audioUrl: audioUri,
      };

      this.conversation.push(userMessage);
      this.onMessageCallback?.(userMessage);

      // Get AI response
      await this.getAIResponse(transcription.text);
    } catch (error) {
      console.error('Error processing audio:', error);
      this.onStatusCallback?.('error');
    }
  }

  private async getAIResponse(userInput: string): Promise<void> {
    if (!this.openai) return;

    try {
      // Prepare conversation context
      const messages = [
        {
          role: 'system' as const,
          content: `Eres un asistente de voz inteligente para la aplicación móvil Nebu. 
          Eres amigable, útil y conversacional. Puedes ayudar con:
          - Información sobre IoT y dispositivos conectados
          - Análisis de datos de sensores
          - Consejos técnicos
          - Conversación general
          
          Responde de manera concisa pero informativa. Habla en español cuando el usuario hable en español.
          Si el usuario pregunta sobre datos de sensores, puedes inventar datos realistas para demostración.`
        },
        ...this.conversation.slice(-5).map(msg => ({
          role: msg.role,
          content: msg.content,
        })),
        {
          role: 'user' as const,
          content: userInput,
        }
      ];

      const completion = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: messages,
        max_tokens: 150,
        temperature: 0.7,
      });

      const aiResponse = completion.choices[0]?.message?.content || 'Lo siento, no pude procesar tu solicitud.';

      const assistantMessage: ConversationMessage = {
        id: Date.now().toString(),
        role: 'assistant',
        content: aiResponse,
        timestamp: Date.now(),
      };

      this.conversation.push(assistantMessage);
      this.onMessageCallback?.(assistantMessage);

      // Convert AI response to speech
      await this.speakResponse(aiResponse);
      await this.saveConversationHistory();
    } catch (error) {
      console.error('Error getting AI response:', error);
      this.onStatusCallback?.('error');
    }
  }

  private async speakResponse(text: string): Promise<void> {
    if (!this.openai) return;

    try {
      this.onStatusCallback?.('speaking');

      // Generate speech using OpenAI TTS
      const mp3 = await this.openai.audio.speech.create({
        model: 'tts-1',
        voice: 'nova', // Female voice, good for Spanish
        input: text,
        speed: 1.0,
      });

      // Convert response to playable format
      const buffer = Buffer.from(await mp3.arrayBuffer());
      const audioUri = `${Audio.getAudioDirectory()}response_${Date.now()}.mp3`;
      
      // Save audio file (simplified for demo)
      // In production, you'd save the buffer to file system
      
      // Play the audio response
      const { sound } = await Audio.Sound.createAsync(
        { uri: audioUri },
        { shouldPlay: true, volume: 1.0 }
      );

      this.sound = sound;

      // Wait for playback to finish
      sound.setOnPlaybackStatusUpdate((status) => {
        if (status.isLoaded && status.didJustFinish) {
          this.onStatusCallback?.('idle');
        }
      });
    } catch (error) {
      console.error('Error generating speech:', error);
      this.onStatusCallback?.('idle');
    }
  }

  async sendTextMessage(text: string): Promise<void> {
    const userMessage: ConversationMessage = {
      id: Date.now().toString(),
      role: 'user',
      content: text,
      timestamp: Date.now(),
    };

    this.conversation.push(userMessage);
    this.onMessageCallback?.(userMessage);

    await this.getAIResponse(text);
  }

  onMessage(callback: (message: ConversationMessage) => void): void {
    this.onMessageCallback = callback;
  }

  onStatusChange(callback: (status: 'idle' | 'listening' | 'processing' | 'speaking' | 'error') => void): void {
    this.onStatusCallback = callback;
  }

  getConversation(): ConversationMessage[] {
    return [...this.conversation];
  }

  async clearConversation(): Promise<void> {
    this.conversation = [];
    await AsyncStorage.removeItem('voice_conversation_history');
  }

  async disconnect(): Promise<void> {
    try {
      if (this.recording) {
        await this.recording.stopAndUnloadAsync();
      }
      if (this.sound) {
        await this.sound.stopAsync();
        await this.sound.unloadAsync();
      }
      
      this.isListening = false;
      this.recording = null;
      this.sound = null;
      this.onStatusCallback?.('idle');
    } catch (error) {
      console.error('Error disconnecting:', error);
    }
  }
}
