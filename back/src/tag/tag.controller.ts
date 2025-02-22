/* eslint-disable prettier/prettier */
import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { TagService } from './tag.service';
import { FirebaseAuthGuard } from 'src/auth/guards/firebase-auth.guard';
import { CreateTagDto } from './dto/create-tag.dto';

@Controller('api/tags')
export class TagController {
    constructor(private readonly tagService: TagService) {}

    @UseGuards(FirebaseAuthGuard)
    @Post()
    async createTag(@Body() createTagDto: CreateTagDto) {
        return this.tagService.create(createTagDto);
    }

    @Get()
    async findAll() {
        return this.tagService.findAll();
    }

    @Get(':tagId')
    async findById(@Param('tagId') tagId: string) {
        return this.tagService.findById(tagId);
    }

    @UseGuards(FirebaseAuthGuard)
    @Put(':tagId')
    async updateTag(
        @Param('tagId') tagId: string,
        @Body() updateTagDto: CreateTagDto,
    ) {
        return this.tagService.updateById(tagId, updateTagDto);
    }

    @UseGuards(FirebaseAuthGuard)
    @Delete(':tagId')
    async removeTag(@Param('tagId') tagId: string) {
        return this.tagService.removeById(tagId);
    }

    @Get('name/:tagName')
    async findByName(@Param('tagName') tagName: string) {
        return this.tagService.findByName(tagName);
    }

}
