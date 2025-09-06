import { LIVEKIT_API_KEY, LIVEKIT_API_SECRET } from '@env';

// Simple JWT implementation for LiveKit tokens
// In production, this should be done on your backend server
export interface TokenClaims {
  iss: string;
  sub: string;
  iat: number;
  exp: number;
  video?: {
    room?: string;
    roomJoin?: boolean;
    canPublish?: boolean;
    canSubscribe?: boolean;
    canPublishData?: boolean;
  };
}

// Base64url encoding
function base64urlEscape(str: string): string {
  return str.replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
}

function base64urlEncode(str: string): string {
  return base64urlEscape(btoa(str));
}

// Simple HMAC-SHA256 implementation
async function hmacSha256(key: string, message: string): Promise<string> {
  const encoder = new TextEncoder();
  const keyBuffer = encoder.encode(key);
  const messageBuffer = encoder.encode(message);
  
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    keyBuffer,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign('HMAC', cryptoKey, messageBuffer);
  const bytes = new Uint8Array(signature);
  const binary = Array.from(bytes, byte => String.fromCharCode(byte)).join('');
  return base64urlEscape(btoa(binary));
}

export async function generateLiveKitToken(
  participantName: string,
  roomName: string,
  ttlSeconds: number = 3600 // 1 hour default
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  
  const header = {
    alg: 'HS256',
    typ: 'JWT'
  };
  
  const payload: TokenClaims = {
    iss: LIVEKIT_API_KEY,
    sub: participantName,
    iat: now,
    exp: now + ttlSeconds,
    video: {
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    }
  };
  
  const encodedHeader = base64urlEncode(JSON.stringify(header));
  const encodedPayload = base64urlEncode(JSON.stringify(payload));
  const message = `${encodedHeader}.${encodedPayload}`;
  
  const signature = await hmacSha256(LIVEKIT_API_SECRET, message);
  
  return `${message}.${signature}`;
}

// Fallback for development - pre-generated tokens
export const getDevToken = async (participantName: string, roomName: string): Promise<string> => {
  try {
    return await generateLiveKitToken(participantName, roomName);
  } catch (error) {
    console.warn('Failed to generate token, using fallback method:', error);
    
    // In case crypto.subtle is not available, return a basic structure
    // This is NOT secure and should only be used for development
    const now = Math.floor(Date.now() / 1000);
    const basicPayload = {
      iss: LIVEKIT_API_KEY,
      sub: participantName,
      exp: now + 3600,
      video: {
        room: roomName,
        roomJoin: true,
        canPublish: true,
        canSubscribe: true,
        canPublishData: true,
      }
    };
    
    // This is just a base64 encoded payload, NOT a valid JWT
    // Use this only for testing connection parameters
    return btoa(JSON.stringify(basicPayload));
  }
};