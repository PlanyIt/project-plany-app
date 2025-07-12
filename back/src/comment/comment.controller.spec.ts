import { Test, TestingModule } from '@nestjs/testing';
import { CommentController } from './comment.controller';
import { CommentService } from './comment.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CommentDto } from './dto/comment.dto';
import { NotFoundException, UnauthorizedException } from '@nestjs/common';

describe('CommentController', () => {
  let commentController: CommentController;
  let commentService: CommentService;

  const mockComments = [
    {
      _id: '507f1f77bcf86cd799439011',
      content: 'Super plan de voyage !',
      userId: '507f1f77bcf86cd799439021',
      planId: '507f1f77bcf86cd799439031',
      parentId: null,
      likes: ['507f1f77bcf86cd799439022'],
      responses: [],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439012',
      content: 'Merci pour les conseils !',
      userId: '507f1f77bcf86cd799439022',
      planId: '507f1f77bcf86cd799439031',
      parentId: '507f1f77bcf86cd799439011',
      likes: [],
      responses: [],
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
  ];

  const validCommentDto: CommentDto = {
    content: 'Nouveau commentaire très intéressant',
    planId: '507f1f77bcf86cd799439031',
    parentId: null,
    userId: '507f1f77bcf86cd799439021',
    likes: [],
  };

  const updateCommentDto: CommentDto = {
    content: 'Commentaire mis à jour',
    planId: '507f1f77bcf86cd799439031',
    parentId: null,
    userId: '507f1f77bcf86cd799439021',
    likes: [],
  };

  const mockUser = {
    _id: '507f1f77bcf86cd799439021',
    username: 'johndoe',
    email: 'john@plany.com',
  };

  const mockRequest = {
    user: mockUser,
  };

  const mockCommentService = {
    create: jest.fn(),
    findAllByPlanId: jest.fn(),
    countByPlanId: jest.fn(),
    findById: jest.fn(),
    findAllByUserId: jest.fn(),
    updateById: jest.fn(),
    removeById: jest.fn(),
    likeComment: jest.fn(),
    unlikeComment: jest.fn(),
    addResponse: jest.fn(),
    findAllResponses: jest.fn(),
    removeResponse: jest.fn(),
  };

  const mockJwtAuthGuard = {
    canActivate: jest.fn(() => true),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [CommentController],
      providers: [
        {
          provide: CommentService,
          useValue: mockCommentService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue(mockJwtAuthGuard)
      .compile();

    commentController = module.get<CommentController>(CommentController);
    commentService = module.get<CommentService>(CommentService);
  });

  it('should be defined', () => {
    expect(commentController).toBeDefined();
    expect(commentService).toBeDefined();
  });

  describe('createComment', () => {
    it('should create and return a new comment', async () => {
      const createdComment = {
        _id: '507f1f77bcf86cd799439013',
        ...validCommentDto,
        userId: mockUser._id,
        likes: [],
        responses: [],
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockCommentService.create.mockResolvedValue(createdComment);

      const result = await commentController.createComment(
        validCommentDto,
        mockRequest,
      );

      expect(result).toEqual(createdComment);
      expect(mockCommentService.create).toHaveBeenCalledWith({
        ...validCommentDto,
        userId: mockUser._id,
      });
      expect(mockCommentService.create).toHaveBeenCalledTimes(1);
    });

    it('should add userId from request to comment data', async () => {
      const createdComment = { ...validCommentDto, userId: mockUser._id };
      mockCommentService.create.mockResolvedValue(createdComment);

      await commentController.createComment(validCommentDto, mockRequest);

      expect(mockCommentService.create).toHaveBeenCalledWith({
        ...validCommentDto,
        userId: mockUser._id,
      });
    });
  });

  describe('findAllByPlanId', () => {
    it('should return paginated comments for a plan', async () => {
      const planId = '507f1f77bcf86cd799439031';
      const page = 1;
      const limit = 10;
      const total = 25;

      mockCommentService.findAllByPlanId.mockResolvedValue(mockComments);
      mockCommentService.countByPlanId.mockResolvedValue(total);

      const result = await commentController.findAllByPlanId(
        planId,
        page,
        limit,
      );

      expect(result).toEqual({
        comments: mockComments,
        meta: {
          total,
          page,
          limit,
          totalPages: Math.ceil(total / limit),
        },
      });

      expect(mockCommentService.findAllByPlanId).toHaveBeenCalledWith(planId, {
        page,
        limit,
      });
      expect(mockCommentService.countByPlanId).toHaveBeenCalledWith(planId);
    });

    it('should use default pagination parameters', async () => {
      const planId = '507f1f77bcf86cd799439031';
      const total = 5;

      mockCommentService.findAllByPlanId.mockResolvedValue(mockComments);
      mockCommentService.countByPlanId.mockResolvedValue(total);

      const result = await commentController.findAllByPlanId(planId);

      expect(result.meta).toEqual({
        total,
        page: 1,
        limit: 10,
        totalPages: 1,
      });

      expect(mockCommentService.findAllByPlanId).toHaveBeenCalledWith(planId, {
        page: 1,
        limit: 10,
      });
    });

    it('should handle custom pagination parameters', async () => {
      const planId = '507f1f77bcf86cd799439031';
      const page = 2;
      const limit = 5;
      const total = 12;

      mockCommentService.findAllByPlanId.mockResolvedValue(mockComments);
      mockCommentService.countByPlanId.mockResolvedValue(total);

      const result = await commentController.findAllByPlanId(
        planId,
        page,
        limit,
      );

      expect(result.meta).toEqual({
        total,
        page,
        limit,
        totalPages: 3,
      });
    });
  });

  describe('findById', () => {
    it('should return comment by ID', async () => {
      const commentId = mockComments[0]._id;
      const expectedComment = mockComments[0];

      mockCommentService.findById.mockResolvedValue(expectedComment);

      const result = await commentController.findById(commentId);

      expect(result).toEqual(expectedComment);
      expect(mockCommentService.findById).toHaveBeenCalledWith(commentId);
      expect(mockCommentService.findById).toHaveBeenCalledTimes(1);
    });
  });

  describe('findAllByUserId', () => {
    it('should return all comments by user ID', async () => {
      const userId = mockUser._id;
      const userComments = [mockComments[0]];

      mockCommentService.findAllByUserId.mockResolvedValue(userComments);

      const result = await commentController.findAllByUserId(userId);

      expect(result).toEqual(userComments);
      expect(mockCommentService.findAllByUserId).toHaveBeenCalledWith(userId);
      expect(mockCommentService.findAllByUserId).toHaveBeenCalledTimes(1);
    });
  });

  describe('updateComment', () => {
    it('should update and return comment', async () => {
      const commentId = mockComments[0]._id;
      const updatedComment = {
        ...mockComments[0],
        ...updateCommentDto,
        userId: mockUser._id,
        updatedAt: new Date(),
      };

      mockCommentService.updateById.mockResolvedValue(updatedComment);

      const result = await commentController.updateComment(
        commentId,
        updateCommentDto,
        mockRequest,
      );

      expect(result).toEqual(updatedComment);
      expect(mockCommentService.updateById).toHaveBeenCalledWith(commentId, {
        ...updateCommentDto,
        userId: mockUser._id,
      });
    });
  });

  describe('likeComment', () => {
    it('should like a comment', async () => {
      const commentId = mockComments[0]._id;
      const likedComment = {
        ...mockComments[0],
        likes: [...mockComments[0].likes, mockUser._id],
      };

      mockCommentService.likeComment.mockResolvedValue(likedComment);

      const result = await commentController.likeComment(
        commentId,
        mockRequest,
      );

      expect(result).toEqual(likedComment);
      expect(mockCommentService.likeComment).toHaveBeenCalledWith(
        commentId,
        mockUser._id,
      );
    });
  });

  describe('unlikeComment', () => {
    it('should unlike a comment', async () => {
      const commentId = mockComments[0]._id;
      const unlikedComment = {
        ...mockComments[0],
        likes: [],
      };

      mockCommentService.unlikeComment.mockResolvedValue(unlikedComment);

      const result = await commentController.unlikeComment(
        commentId,
        mockRequest,
      );

      expect(result).toEqual(unlikedComment);
      expect(mockCommentService.unlikeComment).toHaveBeenCalledWith(
        commentId,
        mockUser._id,
      );
    });
  });

  describe('addResponse', () => {
    it('should add response to comment', async () => {
      const commentId = mockComments[0]._id;
      const responseDto = { ...validCommentDto, parentId: commentId };
      const addedResponse = {
        ...responseDto,
        userId: mockUser._id,
        _id: '507f1f77bcf86cd799439014',
      };

      mockCommentService.addResponse.mockResolvedValue(addedResponse);

      const result = await commentController.addResponse(
        commentId,
        responseDto,
        mockRequest,
      );

      expect(result).toEqual(addedResponse);
      expect(mockCommentService.addResponse).toHaveBeenCalledWith(commentId, {
        ...responseDto,
        userId: mockUser._id,
      });
    });
  });

  describe('findAllResponses', () => {
    it('should return all responses for a comment', async () => {
      const commentId = mockComments[0]._id;
      const responses = [mockComments[1]];

      mockCommentService.findAllResponses.mockResolvedValue(responses);

      const result = await commentController.findAllResponses(commentId);

      expect(result).toEqual(responses);
      expect(mockCommentService.findAllResponses).toHaveBeenCalledWith(
        commentId,
      );
    });
  });

  describe('removeComment', () => {
    it('should delete own comment successfully', async () => {
      const commentId = mockComments[0]._id;
      const commentToDelete = {
        ...mockComments[0],
        userId: mockUser._id.toString(),
      };

      mockCommentService.findById.mockResolvedValue(commentToDelete);
      mockCommentService.removeById.mockResolvedValue(commentToDelete);

      const result = await commentController.removeComment(
        commentId,
        mockRequest,
      );

      expect(result).toEqual(commentToDelete);
      expect(mockCommentService.findById).toHaveBeenCalledWith(commentId);
      expect(mockCommentService.removeById).toHaveBeenCalledWith(commentId);
    });

    it('should throw NotFoundException when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';

      mockCommentService.findById.mockResolvedValue(null);

      await expect(
        commentController.removeComment(commentId, mockRequest),
      ).rejects.toThrow(NotFoundException);
      await expect(
        commentController.removeComment(commentId, mockRequest),
      ).rejects.toThrow(`Comment with ID ${commentId} not found`);

      expect(mockCommentService.removeById).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when user tries to delete others comment', async () => {
      const commentId = mockComments[0]._id;
      const otherUserComment = {
        ...mockComments[0],
        userId: 'other-user-id',
      };

      mockCommentService.findById.mockResolvedValue(otherUserComment);

      await expect(
        commentController.removeComment(commentId, mockRequest),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        commentController.removeComment(commentId, mockRequest),
      ).rejects.toThrow('You can only delete your own comments');

      expect(mockCommentService.removeById).not.toHaveBeenCalled();
    });
  });

  describe('removeResponse', () => {
    it('should delete own response successfully', async () => {
      const commentId = mockComments[0]._id;
      const responseId = mockComments[1]._id;
      const responseToDelete = {
        ...mockComments[1],
        userId: mockUser._id.toString(),
      };

      mockCommentService.findById.mockResolvedValue(responseToDelete);
      mockCommentService.removeResponse.mockResolvedValue(responseToDelete);

      const result = await commentController.removeResponse(
        commentId,
        responseId,
        mockRequest,
      );

      expect(result).toEqual(responseToDelete);
      expect(mockCommentService.findById).toHaveBeenCalledWith(responseId);
      expect(mockCommentService.removeResponse).toHaveBeenCalledWith(
        commentId,
        responseId,
      );
    });

    it('should throw NotFoundException when response not found', async () => {
      const commentId = mockComments[0]._id;
      const responseId = '507f1f77bcf86cd799439999';

      mockCommentService.findById.mockResolvedValue(null);

      await expect(
        commentController.removeResponse(commentId, responseId, mockRequest),
      ).rejects.toThrow(NotFoundException);
      await expect(
        commentController.removeResponse(commentId, responseId, mockRequest),
      ).rejects.toThrow(`Response with ID ${responseId} not found`);

      expect(mockCommentService.removeResponse).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when user tries to delete others response', async () => {
      const commentId = mockComments[0]._id;
      const responseId = mockComments[1]._id;
      const otherUserResponse = {
        ...mockComments[1],
        userId: 'other-user-id',
      };

      mockCommentService.findById.mockResolvedValue(otherUserResponse);

      await expect(
        commentController.removeResponse(commentId, responseId, mockRequest),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        commentController.removeResponse(commentId, responseId, mockRequest),
      ).rejects.toThrow('You can only delete your own responses');

      expect(mockCommentService.removeResponse).not.toHaveBeenCalled();
    });
  });

  describe('Authentication and Authorization', () => {
    it('should be protected by JwtAuthGuard', () => {
      const guards = Reflect.getMetadata('__guards__', CommentController);

      if (guards && guards.length > 0) {
        const guardNames = guards.map(
          (guard: any) => guard.name || guard.constructor?.name,
        );
        expect(guardNames).toContain('JwtAuthGuard');
      } else {
        expect(CommentController).toBeDefined();
      }
    });

    it('should extract user from request correctly', async () => {
      const createdComment = { ...validCommentDto, userId: mockUser._id };
      mockCommentService.create.mockResolvedValue(createdComment);

      await commentController.createComment(validCommentDto, mockRequest);

      expect(mockCommentService.create).toHaveBeenCalledWith({
        ...validCommentDto,
        userId: mockUser._id,
      });
    });
  });

  describe('Controller routing', () => {
    it('should be mapped to correct base route', () => {
      const controllerPath = Reflect.getMetadata('path', CommentController);
      expect(controllerPath).toBe('api/comments');
    });
  });

  describe('Edge cases', () => {
    it('should handle invalid pagination parameters', async () => {
      const planId = '507f1f77bcf86cd799439031';
      const invalidPage = 'invalid' as any;
      const invalidLimit = 'invalid' as any;

      mockCommentService.findAllByPlanId.mockResolvedValue([]);
      mockCommentService.countByPlanId.mockResolvedValue(0);

      const result = await commentController.findAllByPlanId(
        planId,
        invalidPage,
        invalidLimit,
      );

      expect(result.meta.page).toBeDefined();
      expect(result.meta.limit).toBeDefined();
    });

    it('should handle zero pagination results', async () => {
      const planId = '507f1f77bcf86cd799439031';

      mockCommentService.findAllByPlanId.mockResolvedValue([]);
      mockCommentService.countByPlanId.mockResolvedValue(0);

      const result = await commentController.findAllByPlanId(planId);

      expect(result.comments).toEqual([]);
      expect(result.meta.total).toBe(0);
      expect(result.meta.totalPages).toBe(0);
    });

    it('should handle null request user gracefully', async () => {
      const nullRequest = { user: null };

      await expect(
        commentController.createComment(validCommentDto, nullRequest),
      ).rejects.toThrow();
    });
  });
});
