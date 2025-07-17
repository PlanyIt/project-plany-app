import { Test, TestingModule } from '@nestjs/testing';
import { CommentService } from './comment.service';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
 
const mockCommentModelInstance = {
  save: jest.fn(),
};
 
const mockCommentModel = Object.assign(
  function () {
    return mockCommentModelInstance;
  },
  {
    findById: jest.fn(),
    findOne: jest.fn(),
    findOneAndUpdate: jest.fn(),
    find: jest.fn(),
    findByIdAndUpdate: jest.fn(),
    findByIdAndDelete: jest.fn(),
    deleteMany: jest.fn(),
    countDocuments: jest.fn(),
    create: jest.fn(),
    updateOne: jest.fn(),
    exec: jest.fn(),
    populate: jest.fn(),
    // Pour compatibilité, on peut ajouter save ici aussi
    save: jest.fn(),
  },
);
 
describe('CommentService', () => {
  let service: CommentService;
 
  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommentService,
        { provide: getModelToken('Comment'), useValue: mockCommentModel },
      ],
    }).compile();
 
    service = module.get<CommentService>(CommentService);
    // Patch the injected model for direct access
    (service as any).commentModel = mockCommentModel;
  });
 
  it('should be defined', () => {
    expect(service).toBeDefined();
  });
 
  describe('create', () => {
    it('should create and return a comment with user info', async () => {
      const dto = { content: 'test', user: 'userId' };
      const saved = {
        _id: '1',
        ...dto,
      };
      // Simule le comportement du save sur l'instance
      mockCommentModelInstance.save.mockResolvedValue(saved);
      mockCommentModel.findById = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(saved),
      });
      const result = await service.create(dto as any);
      expect(mockCommentModel.findById).toHaveBeenCalledWith('1');
      expect(result).toEqual(saved);
    });
  });
 
  describe('likeComment', () => {
    it('should add a like and return updated comment', async () => {
      const updated = { _id: '1', likes: ['userId'] };
      mockCommentModel.findOneAndUpdate = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(updated),
      });
      const result = await service.likeComment('1', 'userId');
      expect(result).toEqual(updated);
    });
  });
 
  describe('unlikeComment', () => {
    it('should remove a like and return updated comment', async () => {
      const updated = { _id: '1', likes: [] };
      mockCommentModel.findOneAndUpdate = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(updated),
      });
      const result = await service.unlikeComment('1', 'userId');
      expect(result).toEqual(updated);
    });
  });
 
  describe('addResponse', () => {
    it('should add a response to a comment', async () => {
      mockCommentModel.findById = jest.fn().mockReturnValue({
        exec: jest.fn().mockResolvedValue({ _id: 'parentId' }),
      });
      const savedResponse = {
        _id: 'respId',
        parentId: 'parentId',
      };
      // Simule le comportement du save sur l'instance pour la réponse
      mockCommentModelInstance.save.mockResolvedValue(savedResponse);
      mockCommentModel.updateOne = jest.fn().mockResolvedValue({});
      mockCommentModel.populate = jest.fn().mockReturnThis();
      mockCommentModel.findById = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(savedResponse),
      });
      (service as any).commentModel = mockCommentModel;
      const result = await service.addResponse('parentId', {
        content: 'resp',
        user: 'userId',
      } as any);
      expect(result).toEqual(savedResponse);
    });
 
    it('should throw NotFoundException if parent not found', async () => {
      mockCommentModel.findById = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(null) });
      await expect(service.addResponse('badId', {} as any)).rejects.toThrow(
        NotFoundException,
      );
    });
  });
 
  describe('findAllByPlanId', () => {
    it('should return paginated comments for a plan', async () => {
      const comments = [{ _id: '1' }, { _id: '2' }];
      mockCommentModel.find = jest.fn().mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(comments),
      });
      const result = await service.findAllByPlanId('planId', {
        page: 1,
        limit: 2,
      });
      expect(result).toEqual(comments);
    });
  });
 
  describe('removeResponse', () => {
    it('should remove a response from a comment', async () => {
      const comment = { _id: 'parentId', responses: [] };
      const response = { _id: 'respId' };
      mockCommentModel.findByIdAndUpdate = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(comment) });
      mockCommentModel.findByIdAndDelete = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(response) });
      const result = await service.removeResponse('parentId', 'respId');
      expect(result).toEqual({ comment, response });
    });
 
    it('should throw NotFoundException if comment not found', async () => {
      mockCommentModel.findByIdAndUpdate = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(null) });
      await expect(service.removeResponse('badId', 'respId')).rejects.toThrow(
        NotFoundException,
      );
    });
 
    it('should throw NotFoundException if response not found', async () => {
      mockCommentModel.findByIdAndUpdate = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue({}) });
      mockCommentModel.findByIdAndDelete = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(null) });
      await expect(
        service.removeResponse('parentId', 'badResp'),
      ).rejects.toThrow(NotFoundException);
    });
  });
 
  describe('countByPlanId', () => {
    it('should return the count of root comments', async () => {
      mockCommentModel.countDocuments = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(5) });
      const result = await service.countByPlanId('planId');
      expect(result).toBe(5);
    });
  });
 
  describe('findAllResponses', () => {
    it('should return all responses for a comment', async () => {
      const responses = [{ _id: 'r1' }];
      mockCommentModel.find = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(responses),
      });
      const result = await service.findAllResponses('parentId');
      expect(result).toEqual(responses);
    });
  });
 
  describe('findAllByUserId', () => {
    it('should return all comments by a user', async () => {
      const comments = [{ _id: 'c1' }];
      mockCommentModel.find = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(comments),
      });
      const result = await service.findAllByUserId('userId');
      expect(result).toEqual(comments);
    });
  });
 
  describe('findById', () => {
    it('should return a comment by id', async () => {
      const comment = { _id: 'c1' };
      mockCommentModel.findOne = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(comment),
      });
      const result = await service.findById('c1');
      expect(result).toEqual(comment);
    });
  });
 
  describe('removeById', () => {
    it('should remove a comment and its responses', async () => {
      const comment = { _id: 'c1', responses: ['r1', 'r2'] };
      mockCommentModel.findById = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(comment) });
      mockCommentModel.deleteMany = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue({}) });
      mockCommentModel.findByIdAndDelete = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(comment),
      });
      const result = await service.removeById('c1');
      expect(result).toEqual(comment);
    });
 
    it('should throw NotFoundException if comment not found', async () => {
      mockCommentModel.findById = jest
        .fn()
        .mockReturnValue({ exec: jest.fn().mockResolvedValue(null) });
      await expect(service.removeById('badId')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
 
  describe('updateById', () => {
    it('should update and return the comment', async () => {
      const updated = { _id: 'c1', content: 'updated' };
      mockCommentModel.findOneAndUpdate = jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(updated),
      });
      const result = await service.updateById('c1', {
        content: 'updated',
      } as any);
      expect(result).toEqual(updated);
    });
  });
});