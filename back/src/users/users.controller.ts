import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  InternalServerErrorException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('api/users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':firebaseUid')
  findOneByFirebaseUid(@Param('firebaseUid') firebaseUid: string) {
    return this.usersService.findOneByFirebaseUid(firebaseUid);
  }

  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto).catch((error) => {
      console.error("Erreur lors de la création de l'utilisateur :", error);
      throw new InternalServerErrorException();
    });
  }

  @Patch(':firebaseUid')
  updateByFirebaseUid(
    @Param('firebaseUid') firebaseUid: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.usersService.updateByFirebaseUid(firebaseUid, updateUserDto);
  }

  @Delete(':firebaseUid')
  removeByFirebaseUid(@Param('firebaseUid') firebaseUid: string) {
    return this.usersService.removeByFirebaseUid(firebaseUid);
  }

  @Get('username/:username')
  findOneByUsername(@Param('username') username: string) {
    return this.usersService.findOneByUsername(username);
  }

  @Get('email/:email')
  findOneByEmail(@Param('email') email: string) {
    return this.usersService.findOneByEmail(email);
  }
}
