export const mockJwtService = {
  sign: jest.fn(),
  verify: jest.fn(),
  decode: jest.fn(),
  signAsync: jest.fn(),
  verifyAsync: jest.fn(),
};

export const createMockJwtService = () => ({
  sign: jest.fn().mockReturnValue('mocked-jwt-token'),
  verify: jest.fn().mockReturnValue({
    sub: '507f1f77bcf86cd799439011',
    email: 'test@plany.com',
  }),
  decode: jest.fn().mockReturnValue({
    sub: '507f1f77bcf86cd799439011',
    email: 'test@plany.com',
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 3600,
  }),
  signAsync: jest.fn().mockResolvedValue('mocked-jwt-token'),
  verifyAsync: jest.fn().mockResolvedValue({
    sub: '507f1f77bcf86cd799439011',
    email: 'test@plany.com',
  }),
});
