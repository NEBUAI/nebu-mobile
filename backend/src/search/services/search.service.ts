import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Course } from '../../courses/entities/course.entity';

@Injectable()
export class SearchService {
  constructor(
    @InjectRepository(Course)
    private courseRepository: Repository<Course>
  ) {}

  async search(query: string) {
    if (!query || query.trim().length === 0) {
      return {
        results: [],
        total: 0,
        query: query,
      };
    }

    try {
      // Search in courses
      const courses = await this.courseRepository
        .createQueryBuilder('course')
        .where('course.title ILIKE :query OR course.description ILIKE :query', {
          query: `%${query}%`,
        })
        .andWhere('course.isPublished = :published', { published: true })
        .select([
          'course.id',
          'course.title',
          'course.description',
          'course.slug',
          'course.level',
          'course.duration',
        ])
        .limit(10)
        .getMany();

      const results = courses.map(course => ({
        id: course.id.toString(),
        type: 'course' as const,
        title: course.title,
        description: course.description,
        url: `/course/${course.slug}`,
        icon: '📚',
      }));

      return {
        results,
        total: results.length,
        query: query,
      };
    } catch {
      // Search error occurred
      return {
        results: [],
        total: 0,
        query: query,
      };
    }
  }
}
