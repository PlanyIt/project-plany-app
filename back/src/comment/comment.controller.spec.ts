import { Test, TestingModule } from '@nestjs/testing';
import { CommentController } from './comment.controller';
import { CommentService } from './comment.service';
import { PlanService } from '../plan/plan.service';
import { NotFoundException, UnauthorizedException } from '@nestjs/common';

const mockCommentService = {
  create: jest.fn(),
  findAllByPlanId: jest.fn(),
  countByPlanId: jest.fn(),
  findById: jest.fn(),
  findAllByUserId: jest.fn(),
  removeResponse: jest.fn(),
  updateById: jest.fn(),
  likeComment: jest.fn(),
  unlikeComment: jest.fn(),
  addResponse: jest.fn(),
  findAllResponses: jest.fn(),
  removeById: jest.fn(),
};

const mockPlanService = {
  findById: jest.fn(),
};

describe('CommentController', () => {
  let controller: CommentController;

  const reqMock = { user: { _id: 'userId' } };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [CommentController],
      providers: [
        { provide: CommentService, useValue: mockCommentService },
        { provide: PlanService, useValue: mockPlanService },
      ],
    }).compile();

    controller = module.get<CommentController>(CommentController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('createComment', () => {
    it('should create a comment', async () => {
      mockPlanService.findById.mockResolvedValue({ isPublic: true });
      mockCommentService.create.mockResolvedValue({ text: 'ok' });

      await expect(
        controller.createComment({ text: 'ok', planId: 'pid' } as any, reqMock),
      ).resolves.toEqual({ text: 'ok' });

      expect(mockCommentService.create).toHaveBeenCalledWith({
        text: 'ok',
        planId: 'pid',
        user: 'userId',
      });
    });
  });

  describe('findAllByPlanId', () => {
    it('should return comments and meta', async () => {
      mockCommentService.findAllByPlanId.mockResolvedValue(['c1']);
      mockCommentService.countByPlanId.mockResolvedValue(1);
      await expect(controller.findAllByPlanId('pid', 1, 10)).resolves.toEqual({
        comments: ['c1'],
        meta: { total: 1, page: 1, limit: 10, totalPages: 1 },
      });
    });
  });

  describe('findById', () => {
    it('should return comment by id', async () => {
      mockCommentService.findById.mockResolvedValue({ _id: 'cid' });
      await expect(controller.findById('cid')).resolves.toEqual({ _id: 'cid' });
    });
  });

  describe('findAllByUserId', () => {
    it('should return comments by user', async () => {
      mockCommentService.findAllByUserId.mockResolvedValue(['c1']);
      await expect(controller.findAllByUserId('uid')).resolves.toEqual(['c1']);
    });
  });

  describe('removeResponse', () => {
    it('should throw NotFoundException if response not found', async () => {
      mockCommentService.findById.mockResolvedValue(null);
      await expect(
        controller.removeResponse('cid', 'rid', reqMock),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw UnauthorizedException if not owner', async () => {
      mockCommentService.findById.mockResolvedValue({ user: 'other' });
      await expect(
        controller.removeResponse('cid', 'rid', reqMock),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should remove response if owner', async () => {
      mockCommentService.findById.mockResolvedValue({ user: 'userId' });
      mockCommentService.removeResponse.mockResolvedValue('ok');
      await expect(
        controller.removeResponse('cid', 'rid', reqMock),
      ).resolves.toBe('ok');
    });
  });

  describe('updateComment', () => {
    it('should update comment', async () => {
      mockCommentService.updateById.mockResolvedValue({ text: 'updated' });
      await expect(
        controller.updateComment('cid', { text: 'updated' } as any, reqMock),
      ).resolves.toEqual({ text: 'updated' });
      expect(mockCommentService.updateById).toHaveBeenCalledWith('cid', {
        text: 'updated',
        user: 'userId',
      });
    });
  });

  describe('likeComment', () => {
    it('should like comment', async () => {
      mockCommentService.likeComment.mockResolvedValue('liked');
      await expect(controller.likeComment('cid', reqMock)).resolves.toBe(
        'liked',
      );
    });
  });

  describe('unlikeComment', () => {
    it('should unlike comment', async () => {
      mockCommentService.unlikeComment.mockResolvedValue('unliked');
      await expect(controller.unlikeComment('cid', reqMock)).resolves.toBe(
        'unliked',
      );
    });
  });

  describe('addResponse', () => {
    it('should add response', async () => {
      mockCommentService.addResponse.mockResolvedValue('added');
      await expect(
        controller.addResponse('cid', { text: 'r' } as any, reqMock),
      ).resolves.toBe('added');
      expect(mockCommentService.addResponse).toHaveBeenCalledWith('cid', {
        text: 'r',
        user: 'userId',
      });
    });
  });

  describe('findAllResponses', () => {
    it('should return all responses', async () => {
      mockCommentService.findAllResponses.mockResolvedValue(['r1']);
      await expect(controller.findAllResponses('cid')).resolves.toEqual(['r1']);
    });
  });

  describe('removeComment', () => {
    it('should throw NotFoundException if comment not found', async () => {
      mockCommentService.findById.mockResolvedValue(null);
      await expect(controller.removeComment('cid', reqMock)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw UnauthorizedException if not owner', async () => {
      mockCommentService.findById.mockResolvedValue({ user: 'other' });
      await expect(controller.removeComment('cid', reqMock)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should remove comment if owner', async () => {
      mockCommentService.findById.mockResolvedValue({ user: 'userId' });
      mockCommentService.removeById.mockResolvedValue('removed');
      await expect(controller.removeComment('cid', reqMock)).resolves.toBe(
        'removed',
      );
    });
  });
});
