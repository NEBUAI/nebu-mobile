import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Assignment } from '../entities/assignment.entity';
import { AssignmentSubmission, SubmissionStatus } from '../entities/assignment-submission.entity';
import { CreateAssignmentDto } from '../dto/create-assignment.dto';
import { UpdateAssignmentDto } from '../dto/update-assignment.dto';
import { SubmitAssignmentDto } from '../dto/submit-assignment.dto';

@Injectable()
export class AssignmentsService {
  constructor(
    @InjectRepository(Assignment)
    private assignmentRepository: Repository<Assignment>,
    @InjectRepository(AssignmentSubmission)
    private submissionRepository: Repository<AssignmentSubmission>
  ) {}

  async create(createAssignmentDto: CreateAssignmentDto): Promise<Assignment> {
    const assignment = this.assignmentRepository.create(createAssignmentDto);
    return this.assignmentRepository.save(assignment);
  }

  async findAll(params?: {
    courseId?: string;
    lessonId?: string;
    status?: string;
    page?: number;
    limit?: number;
  }): Promise<{ data: Assignment[]; total: number; page: number; limit: number }> {
    const { courseId, lessonId, status, page = 1, limit = 10 } = params || {};

    const query = this.assignmentRepository
      .createQueryBuilder('assignment')
      .leftJoinAndSelect('assignment.course', 'course')
      .leftJoinAndSelect('assignment.lesson', 'lesson');

    if (courseId) {
      query.andWhere('assignment.courseId = :courseId', { courseId });
    }

    if (lessonId) {
      query.andWhere('assignment.lessonId = :lessonId', { lessonId });
    }

    if (status) {
      query.andWhere('assignment.status = :status', { status });
    }

    const [data, total] = await query
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    return { data, total, page, limit };
  }

  async findOne(id: string): Promise<Assignment> {
    const assignment = await this.assignmentRepository.findOne({
      where: { id },
      relations: ['course', 'lesson', 'submissions'],
    });

    if (!assignment) {
      throw new NotFoundException('Assignment not found');
    }

    return assignment;
  }

  async findBySlug(slug: string): Promise<Assignment> {
    const assignment = await this.assignmentRepository.findOne({
      where: { slug },
      relations: ['course', 'lesson', 'submissions'],
    });

    if (!assignment) {
      throw new NotFoundException('Assignment not found');
    }

    return assignment;
  }

  async update(id: string, updateAssignmentDto: UpdateAssignmentDto): Promise<Assignment> {
    const assignment = await this.findOne(id);
    Object.assign(assignment, updateAssignmentDto);
    return this.assignmentRepository.save(assignment);
  }

  async remove(id: string): Promise<void> {
    const assignment = await this.findOne(id);
    await this.assignmentRepository.remove(assignment);
  }

  async submitAssignment(
    userId: string,
    submitAssignmentDto: SubmitAssignmentDto
  ): Promise<AssignmentSubmission> {
    const { assignmentId, content, attachments, notes, metadata } = submitAssignmentDto;

    const assignment = await this.findOne(assignmentId);

    // Check if assignment is still open
    if (assignment.dueDate && new Date() > assignment.dueDate && !assignment.allowLateSubmission) {
      throw new BadRequestException('Assignment deadline has passed');
    }

    // Check if user has reached max submissions
    if (assignment.maxSubmissions > 0) {
      const submissionCount = await this.submissionRepository.count({
        where: { userId, assignmentId },
      });

      if (submissionCount >= assignment.maxSubmissions) {
        throw new BadRequestException('Maximum submissions reached');
      }
    }

    // Check if assignment allows resubmission
    if (!assignment.allowResubmission) {
      const existingSubmission = await this.submissionRepository.findOne({
        where: { userId, assignmentId, status: SubmissionStatus.SUBMITTED },
      });

      if (existingSubmission) {
        throw new BadRequestException('Resubmission not allowed');
      }
    }

    // Check if submission is late
    const isLate = assignment.dueDate && new Date() > assignment.dueDate;
    const latePenalty = isLate ? assignment.latePenalty : 0;

    const submission = this.submissionRepository.create({
      userId,
      assignmentId,
      content,
      attachments: attachments || [],
      notes: notes || null,
      metadata: metadata || null,
      isLate,
      latePenalty,
      maxScore: assignment.points,
      status: SubmissionStatus.SUBMITTED,
      submittedAt: new Date(),
    } as any);

    const savedSubmission = await this.submissionRepository.save(submission);

    // Update assignment statistics
    await this.updateAssignmentStats(assignmentId);

    return Array.isArray(savedSubmission) ? savedSubmission[0] : savedSubmission;
  }

  async getUserSubmissions(userId: string, assignmentId?: string): Promise<AssignmentSubmission[]> {
    const where: Record<string, unknown> = { userId };
    if (assignmentId) {
      where.assignmentId = assignmentId;
    }

    return this.submissionRepository.find({
      where,
      relations: ['assignment'],
      order: { createdAt: 'DESC' },
    });
  }

  async gradeSubmission(
    submissionId: string,
    score: number,
    feedback?: string,
    rubric?: any
  ): Promise<AssignmentSubmission> {
    const submission = await this.submissionRepository.findOne({
      where: { id: submissionId },
    });

    if (!submission) {
      throw new NotFoundException('Submission not found');
    }

    // Apply late penalty if applicable
    let finalScore = score;
    if (submission.isLate && submission.latePenalty > 0) {
      finalScore = score * (1 - submission.latePenalty / 100);
    }

    const percentage = (finalScore / submission.maxScore) * 100;

    submission.score = Math.round(finalScore);
    submission.percentage = percentage;
    submission.feedback = feedback || null;
    submission.rubric = rubric || null;
    submission.status = SubmissionStatus.GRADED;
    submission.gradedAt = new Date();

    return this.submissionRepository.save(submission);
  }

  async returnSubmission(submissionId: string): Promise<AssignmentSubmission> {
    const submission = await this.submissionRepository.findOne({
      where: { id: submissionId },
    });

    if (!submission) {
      throw new NotFoundException('Submission not found');
    }

    submission.status = SubmissionStatus.RETURNED;
    submission.returnedAt = new Date();

    return this.submissionRepository.save(submission);
  }

  async getAssignmentStats(assignmentId: string): Promise<any> {
    await this.findOne(assignmentId);
    const submissions = await this.submissionRepository.find({
      where: { assignmentId, status: SubmissionStatus.SUBMITTED },
    });

    const gradedSubmissions = submissions.filter(s => s.status === SubmissionStatus.GRADED);
    const totalSubmissions = submissions.length;
    const totalGraded = gradedSubmissions.length;
    const averageScore =
      totalGraded > 0
        ? gradedSubmissions.reduce((sum, s) => sum + s.percentage, 0) / totalGraded
        : 0;

    return {
      totalSubmissions,
      totalGraded,
      averageScore,
      completionRate: totalSubmissions > 0 ? (totalGraded / totalSubmissions) * 100 : 0,
    };
  }

  private async updateAssignmentStats(assignmentId: string): Promise<void> {
    const submissions = await this.submissionRepository.find({
      where: { assignmentId, status: SubmissionStatus.SUBMITTED },
    });

    const gradedSubmissions = submissions.filter(s => s.status === SubmissionStatus.GRADED);
    const totalSubmissions = submissions.length;
    const totalGraded = gradedSubmissions.length;
    const averageScore =
      totalGraded > 0
        ? gradedSubmissions.reduce((sum, s) => sum + s.percentage, 0) / totalGraded
        : 0;

    await this.assignmentRepository.update(assignmentId, {
      totalSubmissions,
      totalGraded,
      averageScore,
    });
  }
}
