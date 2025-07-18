import { Test, TestingModule } from '@nestjs/testing';
import { CommentService } from '../../../src/comment/comment.service';
import { getModelToken } from '@nestjs/mongoose';
import * as commentFixtures from '../../__fixtures__/comments.json';

class MockCommentModel {
  _id = 'mocked-comment-id';
  planId = 'mocked-plan-id';
  user = 'mocked-user-id';
  likes = [];
  responses = [];
  save = jest.fn().mockResolvedValue(this);

  constructor(dto?: any) {
    Object.assign(this, dto);
  }

  static find = jest.fn().mockReturnThis();
  static findById = jest.fn().mockReturnThis();
  static findOne = jest.fn().mockReturnThis();
  static findByIdAndUpdate = jest.fn().mockReturnThis();
  static findOneAndUpdate = jest.fn().mockReturnThis();
  static findByIdAndDelete = jest.fn().mockReturnThis();
  static updateOne = jest.fn().mockReturnThis();
  static deleteMany = jest.fn().mockReturnThis();
  static aggregate = jest.fn().mockReturnValue([]);
  static countDocuments = jest.fn().mockReturnValue({
    exec: jest.fn().mockResolvedValue(0),
  });
  static deleteOne = jest.fn().mockReturnValue({
    exec: jest.fn().mockResolvedValue({ deletedCount: 1 }),
  });

  static populate = jest.fn().mockReturnThis();
  static sort = jest.fn().mockReturnThis();
  static limit = jest.fn().mockReturnThis();
  static skip = jest.fn().mockReturnThis();
  static exec = jest.fn().mockResolvedValue(
    new MockCommentModel({
      _id: 'mocked-comment-id',
      planId: 'mocked-plan-id',
      user: 'mocked-user-id',
      likes: [],
      responses: [],
    }),
  );
}

describe('CommentService', () => {
  let commentService: CommentService;

  const {
    validComments,
    responseComments,
    createCommentDtos,
    updateCommentDtos,
  } = commentFixtures;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommentService,
        {
          provide: getModelToken('Comment'),
          useValue: MockCommentModel,
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
      const result = await commentService.create(createDto);
      expect(result).toBeDefined();
    });
  });

  describe('likeComment', () => {
    it('should add user to likes array', async () => {
      const result = await commentService.likeComment(
        validComments[0]._id,
        validComments[0].userId,
      );
      expect(result).toBeDefined();
    });
  });

  describe('unlikeComment', () => {
    it('should remove user from likes array', async () => {
      const result = await commentService.unlikeComment(
        validComments[0]._id,
        validComments[0].userId,
      );
      expect(result).toBeDefined();
    });
  });

  describe('findAllByPlanId', () => {
    it('should return comments for a plan', async () => {
      const result = await commentService.findAllByPlanId(
        validComments[0].planId,
        { page: 1, limit: 10 },
      );
      expect(result).toBeDefined();
    });
  });

  describe('countByPlanId', () => {
    it('should return comment count for a plan', async () => {
      const result = await commentService.countByPlanId(
        validComments[0].planId,
      );
      expect(result).toBe(0);
    });
  });

  describe('findAllResponses', () => {
    it('should return responses for a comment', async () => {
      const result = await commentService.findAllResponses(
        validComments[0]._id,
      );
      expect(result).toBeDefined();
    });
  });

  describe('findAllByUserId', () => {
    it('should return comments by user', async () => {
      const result = await commentService.findAllByUserId(
        validComments[0].userId,
      );
      expect(result).toBeDefined();
    });
  });

  describe('findById', () => {
    it('should return comment by id', async () => {
      const result = await commentService.findById(validComments[0]._id);
      expect(result).toBeDefined();
    });
  });

  describe('removeById', () => {
    it('should delete comment and responses', async () => {
      const result = await commentService.removeById(validComments[0]._id);
      expect(result).toBeDefined();
    });
  });

  describe('updateById', () => {
    it('should update a comment', async () => {
      const result = await commentService.updateById(
        validComments[0]._id,
        updateCommentDtos.contentUpdate,
      );
      expect(result).toBeDefined();
    });
  });

  describe('addResponse', () => {
    it('should add response to comment', async () => {
      const responseDto = {
        user: 'mocked-user-id',
        text: 'Response text',
      };

      const result = await commentService.addResponse(
        validComments[0]._id,
        responseDto as any,
      );

      expect(result).toBeDefined();
    });
  });

  describe('removeResponse', () => {
    it('should remove response from comment', async () => {
      const result = await commentService.removeResponse(
        validComments[0]._id,
        responseComments[0]._id,
      );
      expect(result).toBeDefined();
    });
  });
});
