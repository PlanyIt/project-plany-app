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
import { UserService as UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('api/users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  findAll() {
    return this.userService.findAll();
  }

  @Get(':firebaseUid')
  findOneByFirebaseUid(@Param('firebaseUid') firebaseUid: string) {
    return this.userService.findOneByFirebaseUid(firebaseUid);
  }

  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto).catch((error) => {
      console.error("Erreur lors de la création de l'utilisateur :", error);
      throw new InternalServerErrorException();
    });
  }

  @Patch(':firebaseUid')
  updateByFirebaseUid(
    @Param('firebaseUid') firebaseUid: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.userService.updateByFirebaseUid(firebaseUid, updateUserDto);
  }

  @Delete(':firebaseUid')
  removeByFirebaseUid(@Param('firebaseUid') firebaseUid: string) {
    return this.userService.removeByFirebaseUid(firebaseUid);
  }

  @Get('username/:username')
  findOneByUsername(@Param('username') username: string) {
    return this.userService.findOneByUsername(username);
  }

  @Get('email/:email')
  findOneByEmail(@Param('email') email: string) {
    return this.userService.findOneByEmail(email);
  }
}
