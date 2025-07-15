import { Test, TestingModule } from '@nestjs/testing';
import { CommentService } from './comment.service';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';

describe('CommentService', () => {
  let commentService: CommentService;

  const mockComments = [
    {
      _id: '507f1f77bcf86cd799439031',
      content: 'Super plan de voyage !',
      userId: '507f1f77bcf86cd799439011',
      planId: '507f1f77bcf86cd799439021',
      likes: ['507f1f77bcf86cd799439012'],
      responses: [],
      createdAt: new Date('2024-01-20T10:00:00.000Z'),
      updatedAt: new Date('2024-01-20T10:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439032',
      content: 'Merci pour ce partage !',
      userId: '507f1f77bcf86cd799439012',
      planId: '507f1f77bcf86cd799439021',
      likes: [],
      responses: ['507f1f77bcf86cd799439033'],
      createdAt: new Date('2024-01-20T11:00:00.000Z'),
      updatedAt: new Date('2024-01-20T11:00:00.000Z'),
    },
    {
      _id: '507f1f77bcf86cd799439033',
      content: 'De rien, bon voyage !',
      userId: '507f1f77bcf86cd799439011',
      planId: '507f1f77bcf86cd799439021',
      parentId: '507f1f77bcf86cd799439032',
      likes: [],
      responses: [],
      createdAt: new Date('2024-01-20T12:00:00.000Z'),
      updatedAt: new Date('2024-01-20T12:00:00.000Z'),
    },
  ];

  const createCommentDto = {
    content: 'Excellent plan !',
    userId: '507f1f77bcf86cd799439011',
    planId: '507f1f77bcf86cd799439021',
    likes: [],
    parentId: undefined,
  };

  const updateCommentDto = {
    content: 'Plan mis à jour - encore mieux !',
    userId: '507f1f77bcf86cd799439011',
    planId: '507f1f77bcf86cd799439021',
    likes: [],
    parentId: undefined,
  };

  const responseDto = {
    content: 'Merci pour ton commentaire !',
    userId: '507f1f77bcf86cd799439012',
    planId: '507f1f77bcf86cd799439021',
    likes: [],
    parentId: undefined,
  };

  const mockCommentModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: mockComments[0]._id,
    likes: [],
    responses: [],
    createdAt: mockComments[0].createdAt,
    updatedAt: mockComments[0].updatedAt,
    save: jest.fn().mockResolvedValue({
      _id: mockComments[0]._id,
      ...dto,
      likes: [],
      responses: [],
      createdAt: mockComments[0].createdAt,
      updatedAt: mockComments[0].updatedAt,
    }),
  })) as any;

  mockCommentModel.find = jest.fn().mockReturnValue({
    sort: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockCommentModel.findOne = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockCommentModel.findById = jest.fn().mockReturnValue({
    populate: jest.fn().mockReturnThis(),
    exec: jest.fn(),
  });

  mockCommentModel.findOneAndUpdate = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCommentModel.findByIdAndUpdate = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCommentModel.findByIdAndDelete = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  mockCommentModel.updateOne = jest.fn();
  mockCommentModel.deleteMany = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });
  mockCommentModel.countDocuments = jest.fn().mockReturnValue({
    exec: jest.fn(),
  });

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommentService,
        {
          provide: getModelToken('Comment'),
          useValue: mockCommentModel,
        },
      ],
    }).compile();

    commentService = module.get<CommentService>(CommentService);
  });

  it('should be defined', () => {
    expect(commentService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new comment', async () => {
      const result = await commentService.create(createCommentDto);

      expect(mockCommentModel).toHaveBeenCalledWith(createCommentDto);
      expect(result._id).toBe(mockComments[0]._id);
      expect(result.content).toBe(createCommentDto.content);
      expect(result.userId).toBe(createCommentDto.userId);
      expect(result.planId).toBe(createCommentDto.planId);
    });
  });

  describe('findAllByPlanId', () => {
    it('should return comments for a plan with pagination', async () => {
      const planId = '507f1f77bcf86cd799439021';
      const paginationOptions = { page: 1, limit: 10 };
      const expectedComments = [mockComments[0], mockComments[1]];

      mockCommentModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(expectedComments),
      });

      const result = await commentService.findAllByPlanId(
        planId,
        paginationOptions,
      );

      expect(result).toEqual(expectedComments);
      expect(mockCommentModel.find).toHaveBeenCalledWith({
        planId,
        parentId: { $exists: false },
      });
    });

    it('should return empty array when no comments found', async () => {
      const planId = 'nonexistent';
      const paginationOptions = { page: 1, limit: 10 };

      mockCommentModel.find.mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await commentService.findAllByPlanId(
        planId,
        paginationOptions,
      );

      expect(result).toEqual([]);
    });
  });

  describe('findById', () => {
    it('should return comment when found', async () => {
      const commentId = mockComments[0]._id;
      const expectedComment = mockComments[0];

      mockCommentModel.findOne.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(expectedComment),
      });

      const result = await commentService.findById(commentId);

      expect(result).toEqual(expectedComment);
      expect(mockCommentModel.findOne).toHaveBeenCalledWith({ _id: commentId });
    });

    it('should return null when comment not found', async () => {
      mockCommentModel.findOne.mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await commentService.findById('nonexistent');

      expect(result).toBeNull();
    });
  });

  describe('findAllByUserId', () => {
    it('should return comments by user', async () => {
      const userId = '507f1f77bcf86cd799439011';
      const userComments = [mockComments[0], mockComments[2]];

      mockCommentModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(userComments),
      });

      const result = await commentService.findAllByUserId(userId);

      expect(result).toEqual(userComments);
      expect(mockCommentModel.find).toHaveBeenCalledWith({ userId });
    });
  });

  describe('likeComment', () => {
    it('should add user to likes array', async () => {
      const commentId = mockComments[0]._id;
      const userId = '507f1f77bcf86cd799439013';
      const likedComment = {
        ...mockComments[0],
        likes: [...mockComments[0].likes, userId],
      };

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(likedComment),
      });

      const result = await commentService.likeComment(commentId, userId);

      expect(result).toEqual(likedComment);
      expect(mockCommentModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: commentId },
        { $push: { likes: userId } },
        { new: true },
      );
    });

    it('should return null when comment not found', async () => {
      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await commentService.likeComment('nonexistent', 'userId');

      expect(result).toBeNull();
    });
  });

  describe('unlikeComment', () => {
    it('should remove user from likes array', async () => {
      const commentId = mockComments[0]._id;
      const userId = mockComments[0].likes[0];
      const unlikedComment = {
        ...mockComments[0],
        likes: [],
      };

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(unlikedComment),
      });

      const result = await commentService.unlikeComment(commentId, userId);

      expect(result).toEqual(unlikedComment);
      expect(mockCommentModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: commentId },
        { $pull: { likes: userId } },
        { new: true },
      );
    });
  });

  describe('addResponse', () => {
    it('should add response to comment', async () => {
      const commentId = mockComments[1]._id;
      const parentComment = mockComments[1];
      const responseId = '507f1f77bcf86cd799439034';

      const savedResponse = {
        ...responseDto,
        _id: responseId,
        id: responseId,
        parentId: commentId,
        likes: [],
        responses: [],
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockCommentModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(parentComment),
      });

      mockCommentModel.mockImplementationOnce(() => ({
        ...responseDto,
        _id: responseId,
        id: responseId,
        parentId: commentId,
        save: jest.fn().mockResolvedValue(savedResponse),
      }));

      mockCommentModel.updateOne.mockResolvedValue({ modifiedCount: 1 });

      const result = await commentService.addResponse(commentId, responseDto);

      expect(result).toEqual(savedResponse);
      expect(mockCommentModel.findById).toHaveBeenCalledWith(commentId);
      expect(mockCommentModel.updateOne).toHaveBeenCalledWith(
        { _id: commentId },
        { $push: { responses: responseId } },
      );
    });

    it('should throw NotFoundException when parent comment not found', async () => {
      mockCommentModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        commentService.addResponse('nonexistent', responseDto),
      ).rejects.toThrow(NotFoundException);
      await expect(
        commentService.addResponse('nonexistent', responseDto),
      ).rejects.toThrow('Comment with ID nonexistent not found');
    });
  });

  describe('findAllResponses', () => {
    it('should return all responses for a comment', async () => {
      const commentId = mockComments[1]._id;
      const responses = [mockComments[2]];

      mockCommentModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(responses),
      });

      const result = await commentService.findAllResponses(commentId);

      expect(result).toEqual(responses);
      expect(mockCommentModel.find).toHaveBeenCalledWith({
        parentId: commentId,
      });
    });
  });

  describe('removeResponse', () => {
    it('should remove response and update parent comment', async () => {
      const commentId = mockComments[1]._id;
      const responseId = mockComments[2]._id;
      const updatedComment = {
        ...mockComments[1],
        responses: [],
      };
      const deletedResponse = mockComments[2];

      mockCommentModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedComment),
      });

      mockCommentModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedResponse),
      });

      const result = await commentService.removeResponse(commentId, responseId);

      expect(result.comment).toEqual(updatedComment);
      expect(result.response).toEqual(deletedResponse);
      expect(mockCommentModel.findByIdAndUpdate).toHaveBeenCalledWith(
        commentId,
        { $pull: { responses: responseId } },
        { new: true },
      );
      expect(mockCommentModel.findByIdAndDelete).toHaveBeenCalledWith(
        responseId,
      );
    });

    it('should throw NotFoundException when comment not found', async () => {
      mockCommentModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        commentService.removeResponse('nonexistent', 'responseId'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when response not found', async () => {
      const commentId = mockComments[1]._id;

      mockCommentModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockComments[1]),
      });

      mockCommentModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        commentService.removeResponse(commentId, 'nonexistent'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('countByPlanId', () => {
    it('should return comment count for a plan', async () => {
      const planId = '507f1f77bcf86cd799439021';
      const count = 5;

      mockCommentModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(count),
      });

      const result = await commentService.countByPlanId(planId);

      expect(result).toBe(count);
      expect(mockCommentModel.countDocuments).toHaveBeenCalledWith({ planId });
    });
  });

  describe('updateById', () => {
    it('should update and return comment', async () => {
      const commentId = mockComments[0]._id;
      const updatedComment = {
        ...mockComments[0],
        ...updateCommentDto,
      };

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedComment),
      });

      const result = await commentService.updateById(
        commentId,
        updateCommentDto,
      );

      expect(result).toEqual(updatedComment);
      expect(mockCommentModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: commentId },
        updateCommentDto,
        { new: true },
      );
    });

    it('should return null when comment not found', async () => {
      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await commentService.updateById(
        'nonexistent',
        updateCommentDto,
      );

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should delete comment and its responses', async () => {
      const commentId = mockComments[1]._id;
      const commentWithResponses = {
        ...mockComments[1],
        responses: ['507f1f77bcf86cd799439033'],
      };

      mockCommentModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(commentWithResponses),
      });

      mockCommentModel.deleteMany.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ deletedCount: 1 }),
      });

      mockCommentModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(commentWithResponses),
      });

      const result = await commentService.removeById(commentId);

      expect(result).toEqual(commentWithResponses);
      expect(mockCommentModel.findById).toHaveBeenCalledWith(commentId);
      expect(mockCommentModel.deleteMany).toHaveBeenCalledWith({
        _id: { $in: commentWithResponses.responses },
      });
      expect(mockCommentModel.findByIdAndDelete).toHaveBeenCalledWith(
        commentId,
      );
    });

    it('should throw NotFoundException when comment not found', async () => {
      mockCommentModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(commentService.removeById('nonexistent')).rejects.toThrow(
        NotFoundException,
      );
      await expect(commentService.removeById('nonexistent')).rejects.toThrow(
        'Comment with ID nonexistent not found',
      );
    });

    it('should delete comment without responses', async () => {
      const commentId = mockComments[0]._id;
      const commentWithoutResponses = {
        ...mockComments[0],
        responses: [],
      };

      mockCommentModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(commentWithoutResponses),
      });

      mockCommentModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(commentWithoutResponses),
      });

      const result = await commentService.removeById(commentId);

      expect(result).toEqual(commentWithoutResponses);
      expect(mockCommentModel.deleteMany).not.toHaveBeenCalled();
    });
  });
});
