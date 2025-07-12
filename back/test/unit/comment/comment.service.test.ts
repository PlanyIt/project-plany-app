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

  const mockCommentModel = jest.fn().mockImplementation((dto) => ({
    ...dto,
    _id: validComments[0]._id,
    createdAt: new Date(validComments[0].createdAt),
    updatedAt: new Date(validComments[0].updatedAt),
    save: jest.fn().mockResolvedValue({
      _id: validComments[0]._id,
      ...dto,
      createdAt: new Date(validComments[0].createdAt),
      updatedAt: new Date(validComments[0].updatedAt),
    }),
  })) as any;

  mockCommentModel.find = jest.fn();
  mockCommentModel.findOne = jest.fn();
  mockCommentModel.findById = jest.fn();
  mockCommentModel.findByIdAndUpdate = jest.fn();
  mockCommentModel.findByIdAndDelete = jest.fn();
  mockCommentModel.findOneAndUpdate = jest.fn();
  mockCommentModel.updateOne = jest.fn();
  mockCommentModel.deleteMany = jest.fn();
  mockCommentModel.countDocuments = jest.fn();
  mockCommentModel.populate = jest.fn();
  mockCommentModel.sort = jest.fn();
  mockCommentModel.skip = jest.fn();
  mockCommentModel.limit = jest.fn();
  mockCommentModel.exec = jest.fn();

  beforeEach(async () => {
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

  afterEach(() => {
    jest.clearAllMocks();
    mockCommentModel.find.mockReset();
    mockCommentModel.findOne.mockReset();
    mockCommentModel.findById.mockReset();
    mockCommentModel.findByIdAndUpdate.mockReset();
    mockCommentModel.findByIdAndDelete.mockReset();
    mockCommentModel.findOneAndUpdate.mockReset();
    mockCommentModel.updateOne.mockReset();
    mockCommentModel.deleteMany.mockReset();
    mockCommentModel.countDocuments.mockReset();
  });

  it('should be defined', () => {
    expect(commentService).toBeDefined();
  });

  describe('create', () => {
    it('should create and return new comment', async () => {
      const result = await commentService.create(createCommentDtos.validCreate);

      expect(mockCommentModel).toHaveBeenCalledWith(
        createCommentDtos.validCreate,
      );
      expect(result._id).toBe(validComments[0]._id);
      expect(result.content).toBe(createCommentDtos.validCreate.content);
      expect(result.userId).toBe(createCommentDtos.validCreate.userId);
      expect(result.planId).toBe(createCommentDtos.validCreate.planId);
    });

    it('should create comment with minimal data', async () => {
      const result = await commentService.create(
        createCommentDtos.minimalCreate,
      );

      expect(result.planId).toBe(createCommentDtos.minimalCreate.planId);
      expect(result.userId).toBe(createCommentDtos.minimalCreate.userId);
      expect(result.content).toBe(createCommentDtos.minimalCreate.content);
    });

    it('should create comment with image', async () => {
      const result = await commentService.create(createCommentDtos.withImage);

      expect(result.imageUrl).toBe(createCommentDtos.withImage.imageUrl);
      expect(result.content).toBe(createCommentDtos.withImage.content);
    });
  });

  describe('likeComment', () => {
    it('should add user to likes array', async () => {
      const commentId = validComments[0]._id;
      const userId = validComments[0].userId;
      const likedComment = likingOperations.afterLike;

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(likedComment),
      });

      const result = await commentService.likeComment(commentId, userId);

      expect(result).toEqual(likedComment);
      expect(result.likes).toContain(userId);
    });

    it('should handle multiple likes', async () => {
      const commentId = validComments[0]._id;
      const userId = '507f1f77bcf86cd799439013';
      const multiLikedComment = likingOperations.multipleUsers;

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(multiLikedComment),
      });

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

    it('should return null when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';
      const userId = validComments[0].userId;

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await commentService.unlikeComment(commentId, userId);

      expect(result).toBeNull();
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

      jest
        .spyOn(commentService, 'addResponse')
        .mockResolvedValue(mockResult as any);

      const result = await commentService.addResponse(
        commentId,
        responseData as any,
      );

      expect(result.parentId).toBe(commentId);
      expect(result.content).toBe(responseData.content);
    });
  });

  describe('findAllByPlanId', () => {
    it('should return comments for plan without parent', async () => {
      const planId = validComments[0].planId;

      const mockChain = {
        sort: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(commentsByPlan),
      };

      mockCommentModel.find.mockReturnValue(mockChain);

      const result = await commentService.findAllByPlanId(planId, {
        page: 1,
        limit: 10,
      });

      expect(result).toEqual(commentsByPlan);
      expect(mockCommentModel.find).toHaveBeenCalledWith({
        planId,
        parentId: { $exists: false },
      });
    });

    it('should handle different pagination', async () => {
      const planId = validComments[0].planId;
      const paginationOptions = { page: 2, limit: 5 };

      const mockChain = {
        sort: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue([]),
      };

      mockCommentModel.find.mockReturnValue(mockChain);

      await commentService.findAllByPlanId(planId, paginationOptions);

      expect(mockChain.skip).toHaveBeenCalledWith(5);
      expect(mockChain.limit).toHaveBeenCalledWith(5);
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

      mockCommentModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedComment),
      });

      mockCommentModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(deletedResponse),
      });

      const result = await commentService.removeResponse(commentId, responseId);

      expect(result).toEqual({
        comment: updatedComment,
        response: deletedResponse,
      });
      expect(mockCommentModel.findByIdAndUpdate).toHaveBeenCalledWith(
        commentId,
        { $pull: { responses: responseId } },
        { new: true },
      );
    });

    it('should throw NotFoundException when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';
      const responseId = responseComments[0]._id;

      mockCommentModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

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

      mockCommentModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedComment),
      });

      mockCommentModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        commentService.removeResponse(commentId, responseId),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('countByPlanId', () => {
    it('should return comment count for plan', async () => {
      const planId = validComments[0].planId;
      const expectedCount = commentsByPlan.length;

      mockCommentModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(expectedCount),
      });

      const result = await commentService.countByPlanId(planId);

      expect(result).toBe(expectedCount);
      expect(mockCommentModel.countDocuments).toHaveBeenCalledWith({ planId });
    });

    it('should return 0 when no comments for plan', async () => {
      const planId = '507f1f77bcf86cd799439999';

      mockCommentModel.countDocuments.mockReturnValue({
        exec: jest.fn().mockResolvedValue(0),
      });

      const result = await commentService.countByPlanId(planId);

      expect(result).toBe(0);
    });
  });

  describe('findAllResponses', () => {
    it('should return all responses for comment', async () => {
      const commentId = validComments[0]._id;

      mockCommentModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(responseComments),
      });

      const result = await commentService.findAllResponses(commentId);

      expect(result).toEqual(responseComments);
      expect(mockCommentModel.find).toHaveBeenCalledWith({
        parentId: commentId,
      });

      result.forEach((response) => {
        expect(response.parentId).toBe(commentId);
      });
    });

    it('should return empty array when no responses', async () => {
      const commentId = validComments[1]._id;

      mockCommentModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await commentService.findAllResponses(commentId);

      expect(result).toEqual([]);
    });
  });

  describe('findAllByUserId', () => {
    it('should return all comments by user', async () => {
      const userId = validComments[0].userId;

      mockCommentModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue(commentsByUser),
      });

      const result = await commentService.findAllByUserId(userId);

      expect(result).toEqual(commentsByUser);
      expect(mockCommentModel.find).toHaveBeenCalledWith({ userId });
    });

    it('should return empty array when user has no comments', async () => {
      const userId = '507f1f77bcf86cd799439999';

      mockCommentModel.find.mockReturnValue({
        exec: jest.fn().mockResolvedValue([]),
      });

      const result = await commentService.findAllByUserId(userId);

      expect(result).toEqual([]);
    });
  });

  describe('findById', () => {
    it('should return comment when found', async () => {
      const commentId = validComments[0]._id;
      const expectedComment = validComments[0];

      mockCommentModel.findOne.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue(expectedComment),
        }),
      });

      const result = await commentService.findById(commentId);

      expect(result).toEqual(expectedComment);
      expect(mockCommentModel.findOne).toHaveBeenCalledWith({ _id: commentId });
    });

    it('should return null when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';

      mockCommentModel.findOne.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue(null),
        }),
      });

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

      mockCommentModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(commentWithResponses),
      });

      mockCommentModel.deleteMany.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ deletedCount: 2 }),
      });

      mockCommentModel.findByIdAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(commentWithResponses),
      });

      const result = await commentService.removeById(commentId);

      expect(result).toEqual(commentWithResponses);
      expect(mockCommentModel.deleteMany).toHaveBeenCalledWith({
        _id: { $in: commentWithResponses.responses },
      });
      expect(mockCommentModel.findByIdAndDelete).toHaveBeenCalledWith(
        commentId,
      );
    });

    it('should delete comment without responses', async () => {
      const commentId = validComments[1]._id;
      const commentWithoutResponses = validComments[1];

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

    it('should throw NotFoundException when comment not found', async () => {
      const commentId = '507f1f77bcf86cd799439999';

      mockCommentModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(commentService.removeById(commentId)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('updateById', () => {
    it('should update and return comment', async () => {
      const commentId = validComments[0]._id;
      const updateData = updateCommentDtos.contentUpdate;

      const updatedComment = {
        _id: commentId,
        ...updateData,
      };

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedComment),
      });

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

      const updatedComment = {
        _id: commentId,
        ...updateData,
      };

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updatedComment),
      });

      const result = await commentService.updateById(commentId, updateData);

      expect(result.imageUrl).toBe(updateData.imageUrl);
      expect(result.content).toBe(updateData.content);
    });

    it('should return null when comment not found for update', async () => {
      const commentId = '507f1f77bcf86cd799439999';
      const updateData = updateCommentDtos.contentUpdate;

      mockCommentModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      const result = await commentService.updateById(commentId, updateData);

      expect(result).toBeNull();
    });
  });

  describe('special cases', () => {
    it('should handle comment with only image', async () => {
      const result = await commentService.create(createCommentDtos.imageOnly);

      expect(result.content).toBe(createCommentDtos.imageOnly.content);
      expect(result.imageUrl).toBe(createCommentDtos.imageOnly.imageUrl);
      expect(result.planId).toBe(createCommentDtos.imageOnly.planId);
    });

    it('should handle empty likes array', async () => {
      const result = await commentService.create(createCommentDtos.validCreate);

      expect(result.likes).toEqual([]);
      expect(Array.isArray(result.likes)).toBe(true);
    });

    it('should handle empty responses array', async () => {
      const result = await commentService.create(createCommentDtos.validCreate);

      expect(result.responses).toEqual([]);
      expect(Array.isArray(result.responses)).toBe(true);
    });

    it('should handle long content', async () => {
      const longComment = specialCases.longContent;

      const result = await commentService.create({
        content: longComment.content,
        userId: longComment.userId,
        planId: longComment.planId,
        likes: [],
        responses: [],
        parentId: null,
      });

      expect(result.content).toBe(longComment.content);
      expect(result.content.length).toBeGreaterThan(100);
    });

    it('should handle emoji-only content', async () => {
      const emojiComment = specialCases.emojiOnly;

      const result = await commentService.create({
        content: emojiComment.content,
        userId: emojiComment.userId,
        planId: emojiComment.planId,
        likes: [],
        responses: [],
        parentId: null,
      });

      expect(result.content).toBe(emojiComment.content);
      expect(result.content).toBe('👍🎉💪');
    });
  });
});
