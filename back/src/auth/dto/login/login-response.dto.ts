export class LoginResponseDto {
  /**
   * The access token to be used for authentication
   */
  accessToken: string;

  /**
   * The refresh token to be used for token renewal
   */
  refreshToken: string;

  /**
   * The user ID
   */
  user_id: string;

  /**
   * The user information
   */
  user: {
    /**
     * The unique identifier of the user
     */
    id: string;

    /**
     * The username of the user
     */
    username: string;

    /**
     * The email address of the user
     */
    email: string;

    // ...other user fields...
  };
}
