import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { Review } from '../../community/entities/review.entity';
import { Certificate } from '../../certificates/entities/certificate.entity';
import { AcademyStatsDto } from '../dto/academy-stats.dto';

@Injectable()
export class AcademyService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>,
    @InjectRepository(Review)
    private readonly reviewRepository: Repository<Review>,
    @InjectRepository(Certificate)
    private readonly certificateRepository: Repository<Certificate>
  ) {}

  async getAcademyStats(): Promise<AcademyStatsDto> {
    const [totalStudents, totalCourses, totalReviews, averageRating, totalCertificates] =
      await Promise.all([
        this.userRepository.count(),
        this.courseRepository.count(),
        this.reviewRepository.count(),
        this.getAverageRating(),
        this.certificateRepository.count(),
      ]);

    return {
      totalStudents,
      totalCourses,
      totalReviews,
      averageRating: totalReviews > 0 ? Number(averageRating) || 0 : 0,
      totalCertificates,
    };
  }

  private async getAverageRating(): Promise<number> {
    const result = await this.reviewRepository
      .createQueryBuilder('review')
      .select('AVG(review.rating)', 'average')
      .getRawOne();

    return result?.average || 0;
  }
}
