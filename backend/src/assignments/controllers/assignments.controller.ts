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
import { AssignmentsService } from '../services/assignments.service';
import { CreateAssignmentDto } from '../dto/create-assignment.dto';
import { UpdateAssignmentDto } from '../dto/update-assignment.dto';
import { SubmitAssignmentDto } from '../dto/submit-assignment.dto';

@ApiTags('assignments')
@Controller('assignments')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AssignmentsController {
  constructor(private readonly assignmentsService: AssignmentsService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Create a new assignment' })
  @ApiResponse({ status: 201, description: 'Assignment created successfully' })
  create(@Body() createAssignmentDto: CreateAssignmentDto) {
    return this.assignmentsService.create(createAssignmentDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all assignments' })
  @ApiQuery({ name: 'courseId', required: false, description: 'Filter by course ID' })
  @ApiQuery({ name: 'lessonId', required: false, description: 'Filter by lesson ID' })
  @ApiQuery({ name: 'status', required: false, description: 'Filter by status' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number' })
  @ApiQuery({ name: 'limit', required: false, description: 'Items per page' })
  @ApiResponse({ status: 200, description: 'Assignments retrieved successfully' })
  findAll(@Query() params: any) {
    return this.assignmentsService.findAll(params);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get assignment by ID' })
  @ApiResponse({ status: 200, description: 'Assignment retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Assignment not found' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.assignmentsService.findOne(id);
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Get assignment by slug' })
  @ApiResponse({ status: 200, description: 'Assignment retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Assignment not found' })
  findBySlug(@Param('slug') slug: string) {
    return this.assignmentsService.findBySlug(slug);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Update assignment' })
  @ApiResponse({ status: 200, description: 'Assignment updated successfully' })
  @ApiResponse({ status: 404, description: 'Assignment not found' })
  update(@Param('id', ParseUUIDPipe) id: string, @Body() updateAssignmentDto: UpdateAssignmentDto) {
    return this.assignmentsService.update(id, updateAssignmentDto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Delete assignment' })
  @ApiResponse({ status: 200, description: 'Assignment deleted successfully' })
  @ApiResponse({ status: 404, description: 'Assignment not found' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.assignmentsService.remove(id);
  }

  @Post('submit')
  @ApiOperation({ summary: 'Submit assignment' })
  @ApiResponse({ status: 201, description: 'Assignment submitted successfully' })
  @ApiResponse({
    status: 400,
    description: 'Assignment deadline passed or max submissions reached',
  })
  submitAssignment(@Body() submitAssignmentDto: SubmitAssignmentDto) {
    return this.assignmentsService.submitAssignment(
      submitAssignmentDto.userId,
      submitAssignmentDto
    );
  }

  @Get('user/:userId/submissions')
  @ApiOperation({ summary: 'Get user assignment submissions' })
  @ApiQuery({ name: 'assignmentId', required: false, description: 'Filter by assignment ID' })
  @ApiResponse({ status: 200, description: 'Assignment submissions retrieved successfully' })
  getUserSubmissions(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query('assignmentId') assignmentId?: string
  ) {
    return this.assignmentsService.getUserSubmissions(userId, assignmentId);
  }

  @Post('submissions/:id/grade')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Grade assignment submission' })
  @ApiResponse({ status: 200, description: 'Assignment submission graded successfully' })
  @ApiResponse({ status: 404, description: 'Submission not found' })
  gradeSubmission(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: { score: number; feedback?: string; rubric?: any }
  ) {
    return this.assignmentsService.gradeSubmission(id, body.score, body.feedback, body.rubric);
  }

  @Post('submissions/:id/return')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Return assignment submission to student' })
  @ApiResponse({ status: 200, description: 'Assignment submission returned successfully' })
  @ApiResponse({ status: 404, description: 'Submission not found' })
  returnSubmission(@Param('id', ParseUUIDPipe) id: string) {
    return this.assignmentsService.returnSubmission(id);
  }

  @Get(':id/stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Get assignment statistics' })
  @ApiResponse({ status: 200, description: 'Assignment statistics retrieved successfully' })
  getAssignmentStats(@Param('id', ParseUUIDPipe) id: string) {
    return this.assignmentsService.getAssignmentStats(id);
  }
}
