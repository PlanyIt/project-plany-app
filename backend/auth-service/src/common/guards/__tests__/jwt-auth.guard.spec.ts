/* eslint-disable prettier/prettier */
import { ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { JwtAuthGuard } from '../jwt-auth-guard';

describe('JwtAuthGuard', () => {
  let jwtAuthGuard: JwtAuthGuard;

  beforeEach(() => {
    jwtAuthGuard = new JwtAuthGuard();
  });

  it('should activate the JWT guard', () => {
    const mockExecutionContext = {} as ExecutionContext;
    jest.spyOn(AuthGuard('jwt').prototype, 'canActivate').mockReturnValue(true);

    const result = jwtAuthGuard.canActivate(mockExecutionContext);
    expect(result).toBe(true);
  });
});
