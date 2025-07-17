import { Test, TestingModule } from '@nestjs/testing';
import { CommentService } from '../../../src/comment/comment.service';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import * as commentFixtures from '../../__fixtures__/comments.json';

describe('CommentService', () => {
  let commentService: CommentService;

  const {
    validComments,
    responseComments,
    createCommentDtos,
    updateCommentDtos,
    commentsByPlan,
    commentsByUser,
    likingOperations,
    specialCases,
  } = commentFixtures;

  const createMockQuery = (resolveValue) => ({
    populate: jest.fn().mockReturnThis(),
    sort: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    exec: jest.fn().mockResolvedValue(resolveValue),
  });

  const createPopulatedDocument = (dto) => ({
    ...dto,
    _id: validComments[0]._id,
    createdAt: new Date(),
    updatedAt: new Date(),
    user: {
      _id: dto.user,
      username: 'testuser',
      email: 'test@example.com',
      photoUrl: 'test-photo.jpg',
    },
  });

  const mockCommentModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: validComments[0]._id,
    createdAt: new Date(),
    updatedAt: new Date(),
    save: jest.fn().mockResolvedValue({
      ...dto,
      _id: validComments[0]._id,
    }),
  })) as any;

  mockCommentModel.find = jest.fn(() => createMockQuery(validComments));
  mockCommentModel.findById = jest.fn(() =>
    createMockQuery(createPopulatedDocument(validComments[0])),
  );
  mockCommentModel.findOne = jest.fn(() => createMockQuery(validComments[0]));
  mockCommentModel.findByIdAndUpdate = jest.fn(() =>
    createMockQuery(validComments[0]),
  );
  mockCommentModel.findByIdAndDelete = jest.fn(() =>
    createMockQuery(validComments[0]),
  );
  mockCommentModel.findOneAndUpdate = jest.fn(() =>
    createMockQuery(validComments[0]),
  );
  mockCommentModel.updateOne = jest
    .fn()
    .mockResolvedValue({ acknowledged: true, modifiedCount: 1 });
  mockCommentModel.deleteMany = jest.fn(() =>
    createMockQuery({ deletedCount: 2 }),
  );
  mockCommentModel.aggregate = jest.fn().mockResolvedValue([]);
  mockCommentModel.countDocuments = jest.fn(() => createMockQuery(0));

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommentService,
        {
          provide: getModelToken('Comment'),
          useValue: mockCommentModel,
        },
        {
          provide: 'CACHE_MANAGER',
          useValue: { get: jest.fn(), set: jest.fn(), del: jest.fn() },
        },
      ],
    }).compile();

    commentService = module.get<CommentService>(CommentService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(commentService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new comment', async () => {
      const createDto = createCommentDtos.validCreate;

      mockCommentModel.findById.mockReturnValue(
        createMockQuery(createPopulatedDocument(createDto)),
      );

      const result = await commentService.create(createDto);

      expect(mockCommentModel).toHaveBeenCalledWith(createDto);
      expect(result._id).toBe(validComments[0]._id);
      expect(result.content).toBe(createDto.content);
      expect(result.user).toBeDefined();
    });

    it('should create comment with minimal data', async () => {
      const createDto = createCommentDtos.minimalCreate;

      mockCommentModel.findById.mockReturnValue(
        createMockQuery(createPopulatedDocument(createDto)),
      );

      const result = await commentService.create(createDto);

      expect(result.planId).toBe(createDto.planId);
      expect(result.user).toBeDefined();
      expect(result.content).toBe(createDto.content);
    });

    it('should create comment with image', async () => {
      const createDto = createCommentDtos.withImage;

      mockCommentModel.findById.mockReturnValue(
        createMockQuery({
          ...createPopulatedDocument(createDto),
          imageUrl: createDto.imageUrl,
        }),
      );

      const result = await commentService.create(createDto);

      expect(result.imageUrl).toBe(createDto.imageUrl);
      expect(result.content).toBe(createDto.content);
    });
  });

  describe('likeComment', () => {
    it('should add user to likes array', async () => {
      const commentId = validComments[0]._id;
      const userId = validComments[0].userId;
      const likedComment = likingOperations.afterLike;

      mockCommentModel.findOneAndUpdate.mockReturnValue(
        createMockQuery(likedComment),
      );

      const result = await commentService.likeComment(commentId, userId);

      expect(result).toEqual(likedComment);
      expect(result.likes).toContain(userId);
    });

    it('should handle multiple likes', async () => {
      const commentId = validComments[0]._id;
      const userId = '507f1f77bcf86cd799439013';
      const multiLikedComment = likingOperations.multipleUsers;

      mockCommentModel.findOneAndUpdate.mockReturnValue(
        createMockQuery(multiLikedComment),
      );

      const result = await commentService.likeComment(commentId, userId);

      expect(result.likes).toHaveLength(3);
      expect(result.likes).toContain('507f1f77bcf86cd799439011');
      expect(result.likes).toContain('507f1f77bcf86cd799439012');
      expect(result.likes).toContain('507f1f77bcf86cd799439013');
    });
  });

  describe('unlikeComment', () => {
    it('should remove user from likes array', async () => {
      const commentId = validComments[0]._id;
      const userId = validComments[0].userId;
      const unlikedComment = likingOperations.afterUnlike;

      mockCommentModel.findOneAndUpdate.mockReturnValue(
        createMockQuery(unlikedComment),
      );

      const result = await commentService.unlikeComment(commentId, userId);

      expect(result).toEqual(unlikedComment);
      expect(mockCommentModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: commentId },
        { $pull: { likes: userId } },
        { new: true },
      );
    });

    it('should return null when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';
      const userId = validComments[0].userId;

      mockCommentModel.findOneAndUpdate.mockReturnValue(createMockQuery(null));

      const result = await commentService.unlikeComment(commentId, userId);

      expect(result).toBeNull();
    });
  });

  describe('findAllByPlanId', () => {
    it('should return comments for plan without parent', async () => {
      const planId = validComments[0].planId;

      mockCommentModel.find.mockReturnValue(createMockQuery(commentsByPlan));

      const result = await commentService.findAllByPlanId(planId, {
        page: 1,
        limit: 10,
      });

      expect(result).toEqual(commentsByPlan);
      expect(mockCommentModel.find).toHaveBeenCalledWith({
        planId,
        $or: [{ parentId: { $exists: false } }, { parentId: null }],
      });
    });

    it('should handle different pagination', async () => {
      const planId = validComments[0].planId;
      const paginationOptions = { page: 2, limit: 5 };

      const mockChain = createMockQuery([]);
      mockCommentModel.find.mockReturnValue(mockChain);

      await commentService.findAllByPlanId(planId, paginationOptions);

      expect(mockChain.skip).toHaveBeenCalledWith(5);
      expect(mockChain.limit).toHaveBeenCalledWith(5);
    });
  });

  describe('countByPlanId', () => {
    it('should return comment count for plan', async () => {
      const planId = validComments[0].planId;
      const expectedCount = commentsByPlan.length;

      mockCommentModel.countDocuments.mockReturnValue(
        createMockQuery(expectedCount),
      );

      const result = await commentService.countByPlanId(planId);

      expect(result).toBe(expectedCount);
      expect(mockCommentModel.countDocuments).toHaveBeenCalledWith({
        planId,
        $or: [{ parentId: { $exists: false } }, { parentId: null }],
      });
    });

    it('should return 0 when no comments for plan', async () => {
      const planId = '507f1f77bcf86cd799439999';

      mockCommentModel.countDocuments.mockReturnValue(createMockQuery(0));

      const result = await commentService.countByPlanId(planId);

      expect(result).toBe(0);
    });
  });

  describe('findAllResponses', () => {
    it('should return all responses for comment', async () => {
      const commentId = validComments[0]._id;

      mockCommentModel.find.mockReturnValue(createMockQuery(responseComments));

      const result = await commentService.findAllResponses(commentId);

      expect(result).toEqual(responseComments);
      expect(mockCommentModel.find).toHaveBeenCalledWith({
        parentId: commentId,
      });
    });

    it('should return empty array when no responses', async () => {
      const commentId = validComments[1]._id;

      mockCommentModel.find.mockReturnValue(createMockQuery([]));

      const result = await commentService.findAllResponses(commentId);

      expect(result).toEqual([]);
    });
  });

  describe('findAllByUserId', () => {
    it('should return all comments by user', async () => {
      const userId = validComments[0].userId;

      mockCommentModel.find.mockReturnValue(createMockQuery(commentsByUser));

      const result = await commentService.findAllByUserId(userId);

      expect(result).toEqual(commentsByUser);
      expect(mockCommentModel.find).toHaveBeenCalledWith({ user: userId });
    });

    it('should return empty array when user has no comments', async () => {
      const userId = '507f1f77bcf86cd799439999';

      mockCommentModel.find.mockReturnValue(createMockQuery([]));

      const result = await commentService.findAllByUserId(userId);

      expect(result).toEqual([]);
    });
  });

  describe('findById', () => {
    it('should return comment when found', async () => {
      const commentId = validComments[0]._id;
      const expectedComment = validComments[0];

      mockCommentModel.findOne.mockReturnValue(
        createMockQuery(expectedComment),
      );

      const result = await commentService.findById(commentId);

      expect(result).toEqual(expectedComment);
      expect(mockCommentModel.findOne).toHaveBeenCalledWith({ _id: commentId });
    });

    it('should return null when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';

      mockCommentModel.findOne.mockReturnValue(createMockQuery(null));

      const result = await commentService.findById(commentId);

      expect(result).toBeNull();
    });
  });

  describe('removeById', () => {
    it('should delete comment and its responses', async () => {
      const commentId = validComments[0]._id;
      const commentWithResponses = {
        ...validComments[0],
        responses: [responseComments[0]._id, responseComments[1]._id],
      };

      mockCommentModel.findById.mockReturnValue(
        createMockQuery(commentWithResponses),
      );
      mockCommentModel.deleteMany.mockReturnValue(
        createMockQuery({ deletedCount: 2 }),
      );
      mockCommentModel.findByIdAndDelete.mockReturnValue(
        createMockQuery(commentWithResponses),
      );

      const result = await commentService.removeById(commentId);

      expect(result).toEqual(commentWithResponses);
      expect(mockCommentModel.deleteMany).toHaveBeenCalledWith({
        _id: { $in: commentWithResponses.responses },
      });
    });

    it('should delete comment without responses', async () => {
      const commentId = validComments[1]._id;
      const commentWithoutResponses = validComments[1];

      mockCommentModel.findById.mockReturnValue(
        createMockQuery(commentWithoutResponses),
      );
      mockCommentModel.findByIdAndDelete.mockReturnValue(
        createMockQuery(commentWithoutResponses),
      );

      const result = await commentService.removeById(commentId);

      expect(result).toEqual(commentWithoutResponses);
    });

    it('should throw NotFoundException when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';

      mockCommentModel.findById.mockReturnValue(createMockQuery(null));

      await expect(commentService.removeById(commentId)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('updateById', () => {
    it('should update and return comment', async () => {
      const commentId = validComments[0]._id;
      const updateData = updateCommentDtos.contentUpdate;
      const updatedComment = { _id: commentId, ...updateData };

      mockCommentModel.findOneAndUpdate.mockReturnValue(
        createMockQuery(updatedComment),
      );

      const result = await commentService.updateById(commentId, updateData);

      expect(result).toEqual(updatedComment);
      expect(mockCommentModel.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: commentId },
        updateData,
        { new: true },
      );
    });

    it('should update comment with image', async () => {
      const commentId = validComments[0]._id;
      const updateData = updateCommentDtos.imageUpdate;
      const updatedComment = { _id: commentId, ...updateData };

      mockCommentModel.findOneAndUpdate.mockReturnValue(
        createMockQuery(updatedComment),
      );

      const result = await commentService.updateById(commentId, updateData);

      expect(result.imageUrl).toBe(updateData.imageUrl);
      expect(result.content).toBe(updateData.content);
    });

    it('should return null when comment not found for update', async () => {
      const commentId = '507f1f77bcf86cd799439999';
      const updateData = updateCommentDtos.contentUpdate;

      mockCommentModel.findOneAndUpdate.mockReturnValue(createMockQuery(null));

      const result = await commentService.updateById(commentId, updateData);

      expect(result).toBeNull();
    });
  });

  describe('special cases', () => {
    it('should handle comment with only image', async () => {
      const imageOnlyDto = createCommentDtos.imageOnly;

      mockCommentModel.findById.mockReturnValue(
        createMockQuery(createPopulatedDocument(imageOnlyDto)),
      );

      const result = await commentService.create(imageOnlyDto);

      expect(result.content).toBe(imageOnlyDto.content);
      expect(result.imageUrl).toBe(imageOnlyDto.imageUrl);
    });

    it('should handle empty likes array', async () => {
      const createDto = createCommentDtos.validCreate;

      mockCommentModel.findById.mockReturnValue(
        createMockQuery({
          ...createPopulatedDocument(createDto),
          likes: [],
        }),
      );

      const result = await commentService.create(createDto);

      expect(Array.isArray(result.likes || [])).toBe(true);
    });

    it('should handle empty responses array', async () => {
      const result = await commentService.create(createCommentDtos.validCreate);

      expect(Array.isArray(result.responses || [])).toBe(true);
    });

    it('should handle long content', async () => {
      const longComment = specialCases.longContent;

      const result = await commentService.create({
        content: longComment.content,
        user: longComment.userId,
        planId: longComment.planId,
        likes: [],
        responses: [],
        parentId: null,
      });

      expect(result.content).toBeDefined();
    });

    it('should handle emoji-only content', async () => {
      const emojiComment = specialCases.emojiOnly;

      const result = await commentService.create({
        content: emojiComment.content,
        user: emojiComment.userId,
        planId: emojiComment.planId,
        likes: [],
        responses: [],
        parentId: null,
      });

      expect(result.content).toBeDefined();
    });
  });

  describe('addResponse', () => {
    it('should add response to comment', async () => {
      const commentId = validComments[0]._id;
      const responseData = createCommentDtos.responseCreate;

      const mockResult = {
        _id: responseComments[0]._id,
        ...responseData,
        parentId: commentId,
      };

      mockCommentModel.findById.mockReturnValue(
        createMockQuery(validComments[0]),
      );
      mockCommentModel.findById.mockReturnValue(createMockQuery(mockResult));

      const result = await commentService.addResponse(
        commentId,
        responseData as any,
      );

      expect(result.parentId).toBe(commentId);
      expect(result.content).toBe(responseData.content);
    });
  });

  describe('removeResponse', () => {
    it('should remove response from comment', async () => {
      const commentId = validComments[0]._id;
      const responseId = responseComments[0]._id;
      const updatedComment = {
        _id: commentId,
        content: 'Commentaire parent',
        responses: [],
      };
      const deletedResponse = responseComments[0];

      mockCommentModel.findByIdAndUpdate.mockReturnValue(
        createMockQuery(updatedComment),
      );
      mockCommentModel.findByIdAndDelete.mockReturnValue(
        createMockQuery(deletedResponse),
      );

      const result = await commentService.removeResponse(commentId, responseId);

      expect(result).toEqual({
        comment: updatedComment,
        response: deletedResponse,
      });
    });

    it('should throw NotFoundException when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';
      const responseId = responseComments[0]._id;

      mockCommentModel.findByIdAndUpdate.mockReturnValue(createMockQuery(null));

      await expect(
        commentService.removeResponse(commentId, responseId),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when response not found', async () => {
      const commentId = validComments[0]._id;
      const responseId = '507f1f77bcf86cd799439999';
      const updatedComment = {
        _id: commentId,
        content: 'Commentaire parent',
        responses: [],
      };

      mockCommentModel.findByIdAndUpdate.mockReturnValue(
        createMockQuery(updatedComment),
      );
      mockCommentModel.findByIdAndDelete.mockReturnValue(createMockQuery(null));

      await expect(
        commentService.removeResponse(commentId, responseId),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
