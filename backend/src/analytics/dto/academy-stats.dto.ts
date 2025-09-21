import { ApiProperty } from '@nestjs/swagger';

export class AcademyStatsDto {
  @ApiProperty({ description: 'Total de estudiantes registrados' })
  totalStudents: number;

  @ApiProperty({ description: 'Calificación promedio de todos los cursos' })
  averageRating: number;

  @ApiProperty({ description: 'Total de reseñas' })
  totalReviews: number;

  @ApiProperty({ description: 'Total de cursos disponibles' })
  totalCourses: number;

  @ApiProperty({ description: 'Total de lecciones completadas' })
  totalLessonsCompleted?: number;

  @ApiProperty({ description: 'Total de certificados emitidos' })
  totalCertificates?: number;
}
