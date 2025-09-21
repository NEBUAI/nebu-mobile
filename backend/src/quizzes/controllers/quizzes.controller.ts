import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../auth/decorators/user-role.enum';
import { QuizzesService } from '../services/quizzes.service';
import { CreateQuizDto } from '../dto/create-quiz.dto';
import { UpdateQuizDto } from '../dto/update-quiz.dto';
import { SubmitQuizDto } from '../dto/submit-quiz.dto';

@ApiTags('quizzes')
@Controller('quizzes')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class QuizzesController {
  constructor(private readonly quizzesService: QuizzesService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Create a new quiz' })
  @ApiResponse({ status: 201, description: 'Quiz created successfully' })
  create(@Body() createQuizDto: CreateQuizDto) {
    return this.quizzesService.create(createQuizDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all quizzes' })
  @ApiQuery({ name: 'courseId', required: false, description: 'Filter by course ID' })
  @ApiQuery({ name: 'lessonId', required: false, description: 'Filter by lesson ID' })
  @ApiQuery({ name: 'status', required: false, description: 'Filter by status' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number' })
  @ApiQuery({ name: 'limit', required: false, description: 'Items per page' })
  @ApiResponse({ status: 200, description: 'Quizzes retrieved successfully' })
  findAll(@Query() params: any) {
    return this.quizzesService.findAll(params);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get quiz by ID' })
  @ApiResponse({ status: 200, description: 'Quiz retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.quizzesService.findOne(id);
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Get quiz by slug' })
  @ApiResponse({ status: 200, description: 'Quiz retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  findBySlug(@Param('slug') slug: string) {
    return this.quizzesService.findBySlug(slug);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Update quiz' })
  @ApiResponse({ status: 200, description: 'Quiz updated successfully' })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  update(@Param('id', ParseUUIDPipe) id: string, @Body() updateQuizDto: UpdateQuizDto) {
    return this.quizzesService.update(id, updateQuizDto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Delete quiz' })
  @ApiResponse({ status: 200, description: 'Quiz deleted successfully' })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.quizzesService.remove(id);
  }

  @Post(':id/start')
  @ApiOperation({ summary: 'Start quiz attempt' })
  @ApiResponse({ status: 201, description: 'Quiz attempt started successfully' })
  @ApiResponse({ status: 400, description: 'Maximum attempts reached' })
  startAttempt(@Param('id', ParseUUIDPipe) id: string, @Body() body: { userId: string }) {
    return this.quizzesService.startAttempt(body.userId, id);
  }

  @Post('submit')
  @ApiOperation({ summary: 'Submit quiz' })
  @ApiResponse({ status: 200, description: 'Quiz submitted successfully' })
  @ApiResponse({ status: 404, description: 'Active attempt not found' })
  submitQuiz(@Body() submitQuizDto: SubmitQuizDto) {
    return this.quizzesService.submitQuiz(submitQuizDto.userId, submitQuizDto);
  }

  @Get('user/:userId/attempts')
  @ApiOperation({ summary: 'Get user quiz attempts' })
  @ApiQuery({ name: 'quizId', required: false, description: 'Filter by quiz ID' })
  @ApiResponse({ status: 200, description: 'Quiz attempts retrieved successfully' })
  getUserAttempts(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query('quizId') quizId?: string
  ) {
    return this.quizzesService.getUserAttempts(userId, quizId);
  }

  @Get(':id/stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Get quiz statistics' })
  @ApiResponse({ status: 200, description: 'Quiz statistics retrieved successfully' })
  getQuizStats(@Param('id', ParseUUIDPipe) id: string) {
    return this.quizzesService.getQuizStats(id);
  }
}
