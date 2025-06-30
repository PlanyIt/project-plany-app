// Types pour l'authentification
export interface UserDocument {
  _id: string;
  username: string;
  email: string;
  password: string;
}

export interface JwtPayload {
  sub: string;
  username: string;
  iat?: number;
  exp?: number;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResponse extends AuthTokens {
  user_id: string;
  user: {
    id: string;
    username: string;
    email: string;
  };
}
