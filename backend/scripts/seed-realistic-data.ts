import { NestFactory } from '@nestjs/core';
import { DataSource } from 'typeorm';
import { AppModule } from '../src/app.module';
import { databaseConfig } from '../src/config/database.config';
import { Course, CourseLevel, CourseStatus } from '../src/courses/entities/course.entity';
import { Category } from '../src/courses/entities/category.entity';
import { User, UserRole } from '../src/users/entities/user.entity';

class RealisticDataSeeder {
  private dataSource: DataSource;

  async runSeeding(): Promise<void> {
    try {
      console.log('🎯 Starting realistic data seeding...');
      
      await this.cleanDatabase();
      await this.seedCategories();
      await this.seedUsers();
      await this.seedCourses();
      await this.seedEnrollments();
      await this.showStats();
      
      console.log('✅ Realistic data seeding completed successfully!');
    } catch (error) {
      console.error('❌ Realistic data seeding failed:', error);
      throw error;
    }
  }

  private async cleanDatabase(): Promise<void> {
    console.log('🧹 Cleaning database...');
    
    // Delete in correct order to respect foreign key constraints
    await this.dataSource.query('DELETE FROM course_students');
    await this.dataSource.query('DELETE FROM courses');
    await this.dataSource.query('DELETE FROM categories');
    await this.dataSource.query('DELETE FROM users');
    
    console.log('✅ Database cleaned');
  }

  private async seedCategories(): Promise<void> {
    console.log('🏷️ Seeding categories...');
    
    const categoryRepository = this.dataSource.getRepository(Category);
    
    const categories = [
      {
        name: 'Programación',
        slug: 'programacion',
        description: 'Cursos de programación y desarrollo de software',
        icon: 'code',
        color: '#3B82F6',
        sortOrder: 1
      },
      {
        name: 'Diseño',
        slug: 'diseno',
        description: 'Cursos de diseño gráfico y UX/UI',
        icon: 'palette',
        color: '#8B5CF6',
        sortOrder: 2
      },
      {
        name: 'Marketing',
        slug: 'marketing',
        description: 'Cursos de marketing digital y estrategias',
        icon: 'trending-up',
        color: '#10B981',
        sortOrder: 3
      },
      {
        name: 'Negocios',
        slug: 'negocios',
        description: 'Cursos de emprendimiento y gestión empresarial',
        icon: 'briefcase',
        color: '#F59E0B',
        sortOrder: 4
      },
      {
        name: 'Data Science',
        slug: 'data-science',
        description: 'Cursos de ciencia de datos y análisis',
        icon: 'bar-chart',
        color: '#EF4444',
        sortOrder: 5
      }
    ];

    for (const categoryData of categories) {
      const existingCategory = await categoryRepository.findOne({ where: { slug: categoryData.slug } });
      if (!existingCategory) {
        const category = categoryRepository.create(categoryData);
        await categoryRepository.save(category);
        console.log(`✅ Created category: ${categoryData.name}`);
      }
    }
  }

  private async seedUsers(): Promise<void> {
    console.log('👥 Seeding users...');
    
    const userRepository = this.dataSource.getRepository(User);
    
    // Create instructor
    const instructorData = {
      username: 'instructor',
      password: '$2b$10$rVeNV0cNQVPCBYS99SGBJOUWc0vYskisdlsnlIIizg9OHGi6g9I2e', // password123
      email: 'instructor@outliers.academy',
      firstName: 'Carlos',
      lastName: 'Mendoza',
      role: UserRole.INSTRUCTOR,
      status: 'active' as any,
      emailVerified: true,
      preferredLanguage: 'es',
      timezone: 'America/Lima'
    };

    const existingInstructor = await userRepository.findOne({ where: { email: instructorData.email } });
    if (!existingInstructor) {
      const instructor = userRepository.create(instructorData);
      await userRepository.save(instructor);
      console.log('✅ Created instructor');
    }

    // Create some students with realistic data
    const students = [
      { firstName: 'Ana', lastName: 'García', email: 'ana@example.com' },
      { firstName: 'Luis', lastName: 'Rodríguez', email: 'luis@example.com' },
      { firstName: 'María', lastName: 'López', email: 'maria@example.com' },
      { firstName: 'Carlos', lastName: 'Martínez', email: 'carlos@example.com' },
      { firstName: 'Laura', lastName: 'González', email: 'laura@example.com' }
    ];

    for (const studentData of students) {
      const existingStudent = await userRepository.findOne({ where: { email: studentData.email } });
      if (!existingStudent) {
        const student = userRepository.create({
          ...studentData,
          username: studentData.email.split('@')[0],
          password: '$2b$10$rVeNV0cNQVPCBYS99SGBJOUWc0vYskisdlsnlIIizg9OHGi6g9I2e', // password123
          role: UserRole.STUDENT,
          status: 'active' as any,
          emailVerified: true,
          preferredLanguage: 'es',
          timezone: 'America/Lima'
        });
        await userRepository.save(student);
        console.log(`✅ Created student: ${studentData.firstName} ${studentData.lastName}`);
      }
    }
  }

  private async seedCourses(): Promise<void> {
    console.log('📚 Seeding courses with realistic data...');
    
    const courseRepository = this.dataSource.getRepository(Course);
    const categoryRepository = this.dataSource.getRepository(Category);
    const userRepository = this.dataSource.getRepository(User);

    const instructor = await userRepository.findOne({ where: { role: UserRole.INSTRUCTOR } });
    const categories = await categoryRepository.find();

    const coursesData = [
      {
        title: 'JavaScript Moderno desde Cero',
        slug: 'javascript-moderno-desde-cero',
        description: 'Aprende JavaScript desde los fundamentos hasta las características más modernas del lenguaje. Incluye ES6+, async/await, módulos y más.',
        shortDescription: 'Domina JavaScript moderno con este curso completo',
        price: 99.99,
        discountPrice: 79.99,
        level: CourseLevel.BEGINNER,
        status: CourseStatus.PUBLISHED,
        isFeatured: true,
        tags: ['javascript', 'programming', 'web-development', 'es6'],
        requirements: ['Conocimientos básicos de HTML', 'No se requiere experiencia previa en programación'],
        learningOutcomes: ['Dominar los fundamentos de JavaScript', 'Usar características modernas como ES6+', 'Trabajar con APIs asíncronas', 'Crear aplicaciones web interactivas'],
        targetAudience: ['Principiantes en programación', 'Desarrolladores que quieren actualizarse', 'Estudiantes de informática'],
        duration: 1200, // 20 horas
        lessonsCount: 45,
        studentsCount: 1250,
        averageRating: 4.8,
        reviewsCount: 342,
        viewsCount: 15600,
        categorySlug: 'programacion'
      },
      {
        title: 'React.js Avanzado con TypeScript',
        slug: 'react-avanzado-typescript',
        description: 'Lleva tus habilidades de React al siguiente nivel con TypeScript. Aprende patrones avanzados, optimización de rendimiento y mejores prácticas.',
        shortDescription: 'React profesional con TypeScript y patrones avanzados',
        price: 149.99,
        discountPrice: 119.99,
        level: CourseLevel.INTERMEDIATE,
        status: CourseStatus.PUBLISHED,
        isFeatured: true,
        tags: ['react', 'typescript', 'frontend', 'javascript'],
        requirements: ['Conocimientos sólidos de JavaScript', 'Experiencia básica con React'],
        learningOutcomes: ['Dominar TypeScript con React', 'Implementar patrones avanzados', 'Optimizar el rendimiento de aplicaciones', 'Usar herramientas de desarrollo profesionales'],
        targetAudience: ['Desarrolladores React intermedios', 'Desarrolladores frontend', 'Programadores JavaScript'],
        duration: 1800, // 30 horas
        lessonsCount: 60,
        studentsCount: 890,
        averageRating: 4.9,
        reviewsCount: 156,
        viewsCount: 12300,
        categorySlug: 'programacion'
      },
      {
        title: 'Diseño UX/UI desde Cero',
        slug: 'diseno-ux-ui-desde-cero',
        description: 'Aprende los principios fundamentales del diseño UX/UI, desde la investigación de usuarios hasta la implementación de interfaces.',
        shortDescription: 'Diseña experiencias de usuario excepcionales',
        price: 129.99,
        discountPrice: 99.99,
        level: CourseLevel.BEGINNER,
        status: CourseStatus.PUBLISHED,
        isFeatured: true,
        tags: ['ux', 'ui', 'design', 'figma', 'user-experience'],
        requirements: ['No se requiere experiencia previa', 'Acceso a Figma (gratuito)'],
        learningOutcomes: ['Aplicar principios de UX/UI', 'Realizar investigación de usuarios', 'Crear wireframes y prototipos', 'Diseñar interfaces atractivas y funcionales'],
        targetAudience: ['Diseñadores principiantes', 'Desarrolladores frontend', 'Product managers'],
        duration: 1500, // 25 horas
        lessonsCount: 35,
        studentsCount: 2100,
        averageRating: 4.7,
        reviewsCount: 289,
        viewsCount: 18900,
        categorySlug: 'diseno'
      },
      {
        title: 'Marketing Digital Completo',
        slug: 'marketing-digital-completo',
        description: 'Estrategias completas de marketing digital: SEO, SEM, redes sociales, email marketing y análisis de datos.',
        shortDescription: 'Domina todas las áreas del marketing digital',
        price: 179.99,
        discountPrice: 139.99,
        level: CourseLevel.INTERMEDIATE,
        status: CourseStatus.PUBLISHED,
        isFeatured: false,
        tags: ['marketing', 'seo', 'social-media', 'analytics', 'digital'],
        requirements: ['Conocimientos básicos de negocios', 'Acceso a redes sociales'],
        learningOutcomes: ['Desarrollar estrategias de marketing digital', 'Optimizar para motores de búsqueda', 'Gestionar campañas en redes sociales', 'Analizar métricas y ROI'],
        targetAudience: ['Marketers', 'Emprendedores', 'Profesionales de marketing'],
        duration: 2000, // 33 horas
        lessonsCount: 50,
        studentsCount: 1650,
        averageRating: 4.6,
        reviewsCount: 234,
        viewsCount: 22100,
        categorySlug: 'marketing'
      },
      {
        title: 'Python para Data Science',
        slug: 'python-data-science',
        description: 'Aprende Python desde cero aplicado a la ciencia de datos. Incluye pandas, numpy, matplotlib, scikit-learn y más.',
        shortDescription: 'Python completo para análisis de datos',
        price: 199.99,
        discountPrice: 159.99,
        level: CourseLevel.INTERMEDIATE,
        status: CourseStatus.PUBLISHED,
        isFeatured: true,
        tags: ['python', 'data-science', 'pandas', 'numpy', 'machine-learning'],
        requirements: ['Conocimientos básicos de programación', 'No se requiere experiencia previa en Python'],
        learningOutcomes: ['Dominar Python para análisis de datos', 'Usar librerías como pandas y numpy', 'Crear visualizaciones con matplotlib', 'Implementar algoritmos de machine learning'],
        targetAudience: ['Analistas de datos', 'Científicos de datos', 'Desarrolladores Python'],
        duration: 2400, // 40 horas
        lessonsCount: 70,
        studentsCount: 980,
        averageRating: 4.9,
        reviewsCount: 187,
        viewsCount: 14500,
        categorySlug: 'data-science'
      },
      {
        title: 'Emprendimiento y Startups',
        slug: 'emprendimiento-startups',
        description: 'Desde la idea hasta el lanzamiento: todo lo que necesitas saber para crear y hacer crecer tu startup exitosamente.',
        shortDescription: 'Convierte tu idea en una startup exitosa',
        price: 199.99,
        discountPrice: 159.99,
        level: CourseLevel.BEGINNER,
        status: CourseStatus.PUBLISHED,
        isFeatured: true,
        tags: ['entrepreneurship', 'startup', 'business', 'innovation'],
        requirements: ['Mentalidad emprendedora', 'No se requiere experiencia previa'],
        learningOutcomes: ['Validar ideas de negocio', 'Crear modelos de negocio viables', 'Obtener financiamiento', 'Lanzar y hacer crecer tu startup'],
        targetAudience: ['Emprendedores', 'Estudiantes de negocios', 'Profesionales que quieren emprender'],
        duration: 2400, // 40 horas
        lessonsCount: 55,
        studentsCount: 980,
        averageRating: 4.8,
        reviewsCount: 187,
        viewsCount: 14500,
        categorySlug: 'negocios'
      }
    ];

    for (const courseData of coursesData) {
      const existingCourse = await courseRepository.findOne({ where: { slug: courseData.slug } });
      if (!existingCourse) {
        const category = categories.find(c => c.slug === courseData.categorySlug);
        if (category) {
          const { categorySlug, ...courseDataWithoutSlug } = courseData;
          const course = courseRepository.create({
            ...courseDataWithoutSlug,
            instructor: instructor,
            category: category,
            publishedAt: new Date(),
            createdAt: new Date(),
            updatedAt: new Date()
          });
          await courseRepository.save(course);
          console.log(`✅ Created course: ${courseData.title}`);
        }
      }
    }
  }

  private async seedEnrollments(): Promise<void> {
    console.log('📚 Seeding course enrollments...');
    
    const userRepository = this.dataSource.getRepository(User);
    const courseRepository = this.dataSource.getRepository(Course);

    // Get all students
    const students = await userRepository.find({ where: { role: UserRole.STUDENT } });
    console.log(`Found ${students.length} students`);

    // Get all published courses
    const courses = await courseRepository.find({ where: { status: CourseStatus.PUBLISHED } });
    console.log(`Found ${courses.length} courses`);

    // Create realistic enrollments
    const enrollments = [];
    
    // Each student enrolls in 2-4 courses randomly
    for (const student of students) {
      const numCourses = Math.floor(Math.random() * 3) + 2; // 2-4 courses
      const shuffledCourses = courses.sort(() => 0.5 - Math.random());
      const selectedCourses = shuffledCourses.slice(0, numCourses);
      
      for (const course of selectedCourses) {
        enrollments.push({
          courseId: course.id,
          userId: student.id
        });
      }
    }

    // Insert enrollments one by one to avoid SQL syntax issues
    if (enrollments.length > 0) {
      for (const enrollment of enrollments) {
        await this.dataSource.query(`
          INSERT INTO course_students ("courseId", "userId") 
          VALUES ($1, $2)
          ON CONFLICT ("courseId", "userId") DO NOTHING
        `, [enrollment.courseId, enrollment.userId]);
      }
      
      console.log(`✅ Created ${enrollments.length} enrollments`);
    }
  }

  private async showStats(): Promise<void> {
    console.log('\n📊 Database Statistics:');
    
    const [
      totalUsers,
      totalStudents,
      totalInstructors,
      totalCourses,
      totalCategories,
      totalEnrollments
    ] = await Promise.all([
      this.dataSource.query('SELECT COUNT(*) as count FROM users'),
      this.dataSource.query('SELECT COUNT(*) as count FROM users WHERE role = $1', ['student']),
      this.dataSource.query('SELECT COUNT(*) as count FROM users WHERE role = $1', ['instructor']),
      this.dataSource.query('SELECT COUNT(*) as count FROM courses'),
      this.dataSource.query('SELECT COUNT(*) as count FROM categories'),
      this.dataSource.query('SELECT COUNT(*) as count FROM course_students')
    ]);

    console.log(`👥 Users: ${totalUsers[0].count}`);
    console.log(`🎓 Students: ${totalStudents[0].count}`);
    console.log(`👨‍🏫 Instructors: ${totalInstructors[0].count}`);
    console.log(`📚 Courses: ${totalCourses[0].count}`);
    console.log(`🏷️ Categories: ${totalCategories[0].count}`);
    console.log(`📝 Enrollments: ${totalEnrollments[0].count}`);
    console.log('');
  }
}

async function bootstrap() {
  let app;
  try {
    app = await NestFactory.createApplicationContext(AppModule);
    const dataSource = app.get(DataSource);
    
    const seeder = new RealisticDataSeeder();
    (seeder as any).dataSource = dataSource;
    
    await seeder.runSeeding();
    
    console.log('🔄 Closing database connections...');
    await dataSource.destroy();
    
    console.log('🔄 Closing NestJS application...');
    await app.close();
    
    console.log('✅ All connections closed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during seeding:', error);
    if (app) {
      try {
        await app.close();
      } catch (closeError) {
        console.error('❌ Error closing app:', closeError);
      }
    }
    process.exit(1);
  }
}

// Handle process termination gracefully
process.on('SIGINT', () => {
  console.log('\n⚠️ Received SIGINT, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n⚠️ Received SIGTERM, shutting down gracefully...');
  process.exit(0);
});

bootstrap().catch((error) => {
  console.error('❌ Bootstrap failed:', error);
  process.exit(1);
});
